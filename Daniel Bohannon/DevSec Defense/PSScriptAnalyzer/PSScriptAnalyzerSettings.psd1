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



# Note: This is a personal project developed by Daniel Bohannon while an employee at MANDIANT, A FireEye Company.

# PSScriptAnalyzerSettings.psd1

@{
    IncludeRules = @('Measure-TickUsageInCommand',
                     'Measure-TickUsageInArgument',
                     'Measure-TickUsageInMember',
                     'Measure-NonAlphanumericUsageInMember',
                     'Measure-NonAlphanumericUsageInVariable',
                     'Measure-LongMemberValue')
}