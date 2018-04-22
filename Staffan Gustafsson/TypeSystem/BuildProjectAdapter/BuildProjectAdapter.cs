using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Reflection;
using Microsoft.Build.Evaluation;
using Microsoft.Build.Utilities;

namespace PowerCode {
    public class ModuleInitializer : IModuleAssemblyInitializer {
        public void OnImport() {
            AddTypeAccelerator("proj", typeof(Project));

            var td = new[] {
                new TypeData(typeof(Project)) {
                    TypeAdapter   = typeof(ProjectAdapter),
                    TypeConverter = typeof(ProjectConverter),
                },
                new TypeData(typeof(Items)){
                    TypeAdapter = typeof(ProjectAdapter)
                }
            };

            // Here's how you call a PowerShell cmdlet from C# code
            using (var ps = PowerShell.Create(RunspaceMode.CurrentRunspace)) {
                ps.AddCommand("Update-TypeData", true)
                  .AddParameter("TypeData", td);
                ps.Invoke();
                if (ps.HadErrors) {
                    var errorRecords = ps.Streams.Error.ReadAll();
                    throw errorRecords.First().Exception;
                }
            }

            InitMsBuild();
        }

        private void AddTypeAccelerator(string name, Type type) {
            var typeAcceleratorsType = typeof(PSObject).Assembly.GetType("System.Management.Automation.TypeAccelerators");
            var method = typeAcceleratorsType.GetMethod("Add", BindingFlags.Public | BindingFlags.Static);
            method.Invoke(null, new object[] { name, type });
        }

        public static void InitMsBuild() {
            // Force loading of a dependent assembly
            var a = typeof(ToolLocationHelper).FullName;
        }
    }

    public class Items {
        private readonly Project _project;
        public Items(Project project) {
            _project = project;
        }

        public PSAdaptedProperty GetProperty(string propertyName) {
            return new PSAdaptedProperty(propertyName, this);
        }

        public ICollection<ProjectItem> GetPropertyValue(string propertyName) {
            return _project.GetItems(propertyName);
        }

        public Collection<PSAdaptedProperty> GetProperties() {
            var res = new Collection<PSAdaptedProperty>();
            var kinds = _project.AllEvaluatedItems.Distinct(new NameEqualityComparer()).Select(c => new PSAdaptedProperty(c.ItemType, this));
            foreach (var itemType in kinds) {
                res.Add(itemType);
            }
            return res;
        }
    }

    class NameEqualityComparer : IEqualityComparer<ProjectItem> {
        public bool Equals(ProjectItem x, ProjectItem y) => String.Equals(x?.ItemType, y?.ItemType);
        public int GetHashCode(ProjectItem obj) => obj.GetHashCode();
    }

    //[TypeConverter(typeof(ProjectConverter))]
    public class ProjectAdapter : PSPropertyAdapter {
        public override Collection<PSAdaptedProperty> GetProperties(object baseObject) {
            switch (baseObject) {
                case Microsoft.Build.Evaluation.Project proj: {
                        return new Collection<PSAdaptedProperty>()
                        {
                        GetProperty(baseObject, "ClCompile"),
                        GetProperty(baseObject, "Link"),
                        GetProperty(baseObject, "IncludePath"),
                        GetProperty(baseObject, "LibPath"),
                        GetProperty(baseObject, "Libs"),
                        GetProperty(baseObject, "Defines"),
                        GetProperty(baseObject, "Directory"),
                        GetProperty(baseObject, "Fullname"),
                        GetProperty(baseObject, "ProjectItems"),
                        GetProperty(baseObject, "ImportedProjects"),
                    };
                    }
                case Items items:
                    return items.GetProperties();
                default:
                    return null;
            }
        }

        public override PSAdaptedProperty GetProperty(object baseObject, string propertyName) {
            switch (baseObject) {

                case Project proj:
                    switch (propertyName.ToLowerInvariant()) {
                        case "clcompile":
                        case "link":
                        case "includepath":
                        case "libpath":
                        case "libs":
                        case "defines":
                        case "directory":
                        case "fullname":
                        case "importedprojects":
                            return new PSAdaptedProperty(propertyName, proj);
                        case "projectitems":
                            return new PSAdaptedProperty(propertyName, new Items(proj));
                    }
                    break;
                case Items items:
                    return items.GetProperty(propertyName);
            }
            return null;
        }

        public override bool IsSettable(PSAdaptedProperty adaptedProperty) => false;

        public override bool IsGettable(PSAdaptedProperty adaptedProperty) => true;

        public override object GetPropertyValue(PSAdaptedProperty adaptedProperty) {
            string[] filterItemMetaData(ICollection<ProjectMetadata> input, string metaName, string itemType) {
                return input
                        .Where(m => m.ItemType == itemType && m.Name == metaName)
                        .Select(md => md.EvaluatedValue.Split(';').Where(c => !string.IsNullOrWhiteSpace(c)))
                        .SelectMany(c => c).ToArray();
            }
            switch (adaptedProperty.BaseObject) {

                case Project proj: {
                        switch (adaptedProperty.Name.ToLowerInvariant()) {
                            case "clcompile":
                                return proj.AllEvaluatedItems.Where(i => i.ItemType == "ClCompile")
                                           .Select(i => new KeyValuePair<string, string>(i.ItemType, i.EvaluatedInclude))
                                           .ToArray();
                            case "link":
                                return proj.AllEvaluatedItems.Where(i => i.ItemType == "Link")
                                           .Select(i => new KeyValuePair<string, string>(i.ItemType, i.EvaluatedInclude))
                                           .ToArray();
                            case "includepath":
                                return filterItemMetaData(proj.AllEvaluatedItemDefinitionMetadata, "AdditionalIncludeDirectories", "ClCompile");
                            case "libpath":
                                return filterItemMetaData(proj.AllEvaluatedItemDefinitionMetadata, "AdditionalLibraryDirectories", "Link");
                            case "libs":
                                return filterItemMetaData(proj.AllEvaluatedItemDefinitionMetadata, "AdditionalDependencies", "Link");
                            case "defines":
                                return filterItemMetaData(proj.AllEvaluatedItemDefinitionMetadata, "PreprocessorDefinitions", "ClCompile");
                            case "directory": return proj.DirectoryPath;
                            case "fullname":
                                return proj.FullPath;
                            case "importedprojects":
                                return proj.Imports.Select(c => c.ImportedProject.FullPath).ToArray();
                            case "projectitems":
                                return new Items(proj);
                        }
                        break;
                    }
                case Items items:
                    return items.GetPropertyValue(adaptedProperty.Name);
            }
            return null;
        }

        public override void SetPropertyValue(PSAdaptedProperty adaptedProperty, object value) {}

        public override string GetPropertyTypeName(PSAdaptedProperty adaptedProperty) {
            if (adaptedProperty.BaseObject is Microsoft.Build.Evaluation.Project proj) {
                switch (adaptedProperty.Name) {
                    case "ClCompile": return "KeyValuePair<string, string>[]";
                    case "IncludePath": return "System.String[]";
                    case "LibPath": return "System.String[]";
                    case "Libs": return "System.String[]";
                    case "Defines": return "System.String[]";
                    case "Directory": return "System.String";
                    case "Fullname": return "System.String";
                    case "ImportedProjects": return "System.String[]";
                    case "ProjectItems": return "PowerCode.Items";
                }
            }
            else if (adaptedProperty.BaseObject is Items items) {
                return typeof(Collection<Project>).FullName;
            }
            return null;
        }
    }

    public class ProjectConverter : PSTypeConverter {
        public override bool CanConvertTo(PSObject sourceValue, Type destinationType) => false;

        public override bool CanConvertTo(object sourceValue, Type destinationType) => false;

        public override bool CanConvertFrom(PSObject sourceValue, Type destinationType) => CanConvertFrom(sourceValue.BaseObject, destinationType);

        public override bool CanConvertFrom(object sourceValue, Type destinationType) =>
            destinationType == typeof(Project) && sourceValue is string s &&
                   (s.EndsWith("proj", StringComparison.OrdinalIgnoreCase) && File.Exists(s));

        public override object ConvertFrom(object sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase) {
            var vspath = @"C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\";
            if (!(sourceValue is string path && destinationType == typeof(Project)))
                return null;

            var globalProperties = new Dictionary<string, string>
            {
                { "DesignTimeBuild", "true" },
                { "Configuration", "Debug" },
                { "VsInstallRoot", $"{vspath}"},
                { "VCTargetsPath", $@"{vspath}Common7\IDE\VC\VCTargets\"}
            };

            ProjectCollection projectCollection = new ProjectCollection(ToolsetDefinitionLocations.Registry);

            var props15 = new Dictionary<string, string>
            {
                { "MSBuildSDKsPath", $@"{vspath}MSBuild\Sdks"},
                { "RoslynTargetsPath", $@"{vspath}MSBuild\15.0\Bin\Roslyn"}
            };
            projectCollection.AddToolset(new Toolset("15.0", $@"{vspath}MSBuild\15.0\Bin", props15, projectCollection, null));

            return new Project(path, globalProperties, "15.0", projectCollection);
        }

        public override object ConvertFrom(PSObject sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
            => ConvertFrom(sourceValue?.BaseObject, destinationType, formatProvider, ignoreCase);

        public override object ConvertTo(PSObject sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase) => null;

        public override object ConvertTo(object sourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase) => null;
    }
}
