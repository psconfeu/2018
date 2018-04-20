#   This file is part of DevSec Defense.
#
#   Copyright 2018 Daniel Bohannon <@danielhbohannon>
#         while at Mandiant <http://www.mandiant.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.



# PSScriptAnalyzer wrapper module Measure-SAObfuscation.

# (Ex. 1 of 4) Invoke-Obfuscation
$res = Measure-SAObfuscation .\Samples\Obfuscated\InvokeObfuscation\
# Group counts for ScriptAnalyzer rule hits.
$res.ScriptAnalyzerResult | Group-Object RuleName | Sort-Object Count -Descending | Select-Object Count,Name

# (Ex. 2 of 4) Invoke-CradleCrafter
$res = Measure-SAObfuscation .\Samples\Obfuscated\InvokeCradleCrafter\
# Group counts for ScriptAnalyzer rule hits.
$res.ScriptAnalyzerResult | Group-Object RuleName | Sort-Object Count -Descending | Select-Object Count,Name

# (Ex. 3 of 4) ISESteroids
$res = Measure-SAObfuscation .\Samples\Obfuscated\ISESteroids\
# Group counts for ScriptAnalyzer rule hits.
$res.ScriptAnalyzerResult | Group-Object RuleName | Sort-Object Count -Descending | Select-Object Count,Name

# (Ex. 4 of 4) Non-Obfuscated / Clean.
$res = Measure-SAObfuscation .\Samples\Clean\