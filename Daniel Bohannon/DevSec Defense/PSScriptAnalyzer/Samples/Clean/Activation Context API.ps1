<#
By Adam Driscoll
12/14/2012
Twitter: @adamdriscoll
More Information: http://csharpening.net/?p=1427

Description:
    Functions for entering and exiting an activation context. This provides support for registration free COM in PowerShell. 
#>
Add-Type -TypeDefinition '

namespace Driscoll
{
using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

public class ActivationContext
{
    IntPtr hActCtx;
    uint cookie;

        public void CreateAndActivate(string manifest)
        {
            var actCtx = new ACTCTX();
            actCtx.cbSize = Marshal.SizeOf(typeof(ACTCTX));
            actCtx.dwFlags = 0;
            actCtx.lpSource = manifest;
            actCtx.lpResourceName = null;

            hActCtx = CreateActCtx(ref actCtx);
            if(hActCtx == new IntPtr(-1))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to create activation context.");
            }

            if (!ActivateActCtx(hActCtx, out cookie))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Failed to activate activation context.");
            }
        }

        public void DeactivateAndFree()
        {
            DeactivateActCtx(0, cookie);
            ReleaseActCtx(hActCtx);
        }

       [DllImport("kernel32.dll")]
        private static extern IntPtr CreateActCtx(ref ACTCTX actctx);

        [StructLayout(LayoutKind.Sequential)]
        private struct ACTCTX
        {
            public int cbSize;
            public uint dwFlags;
            public string lpSource;
            public ushort wProcessorArchitecture;
            public ushort wLangId;
            public string lpAssemblyDirectory;
            public string lpResourceName;
            public string lpApplicationName;
        }

        [DllImport("Kernel32.dll", SetLastError = true)]
        private extern static bool ActivateActCtx(IntPtr hActCtx, out uint lpCookie);

        [DllImport("Kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool DeactivateActCtx(int dwFlags, uint lpCookie);

        [DllImport("Kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool ReleaseActCtx(IntPtr hActCtx);

        private const uint ACTCTX_FLAG_PROCESSOR_ARCHITECTURE_VALID = 0x001;
        private const uint ACTCTX_FLAG_LANGID_VALID = 0x002;
        private const uint ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID = 0x004;
        private const uint ACTCTX_FLAG_RESOURCE_NAME_VALID = 0x008;
        private const uint ACTCTX_FLAG_SET_PROCESS_DEFAULT = 0x010;
        private const uint ACTCTX_FLAG_APPLICATION_NAME_VALID = 0x020;
        private const uint ACTCTX_FLAG_HMODULE_VALID = 0x080;

        private const UInt16 RT_MANIFEST = 24;
        private const UInt16 CREATEPROCESS_MANIFEST_RESOURCE_ID = 1;
        private const UInt16 ISOLATIONAWARE_MANIFEST_RESOURCE_ID = 2;
        private const UInt16 ISOLATIONAWARE_NOSTATICIMPORT_MANIFEST_RESOURCE_ID = 3;

        private const uint FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100;
        private const uint FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200;
        private const uint FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
        }
        }
'

function Enter-ActivationContext
{
    param($manifest)

    $global:ActivationContext = New-Object Driscoll.ActivationContext
    $global:ActivationContext.CreateAndActivate($manifest)
}


function Exit-ActivationContext
{
    $global:ActivationContext.DeactivateAndFree()
}

