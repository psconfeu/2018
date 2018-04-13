# PlatyPS: from 0 to 1 and beyond

**The materials for workshop are located at https://github.com/vors/psconfeu-2018-workshop** 

## Abstract

Do you suffer from un(der)documented PowerShell code? Or, is it your hair that is constantly on fire, and you simply do not have the time to add proper documentation to your code?
 
That’s common place, look around - yet it’s not very clever. PowerShell scripts become integral part of your business logic. Without documentation, you waste time for others to service your code, and may even violate legal requirements. As a professional PowerShell scripter, you want to make sure your code is accompanied by professional-looking and complete documentation. Just how do you approach this?
 
Lean back, join this workshop, and become friends with PlatyPS! PlatyPS is the new tool used by both Microsoft and Community that help you to create professional documentation for your PowerShell projects in no time:
 
- Just how do you (quickly) add good documentation to your existing code? PlatyPS is the answer: fast bootstrapping for existing projects!
- How can documentation show both in the PowerShell help system, and can be published to websites? PlatyPS is the answer: compatible both with maml and markdown, documentation displays in PS help system and on websites
- How do you maintain and update your documentation with new versions of your code, and new functions or new parameters introduced? PlatyPS is the answer: version control friendly documentation, support for updating existing help
- Finally: how do you work as a team? PlatyPS is the answer: enable others to contribute to your documentation with ease.
 
PlatyPS adds the professional touch to your PS projects, and is completely free. Join the list of these popular modules that already use platyPS: Azure-Powershell, Powershell-Docs, PSReadLine.

In this workshop we will cover:

- onboarding for an existing project (bring your own or use a sample one!)
- standard workflow for platyPS: creating new help, updating help, creating maml from markdown.
- hosting your markdown documentation.
- best practices of markdown authoring.
- Continuous Integration - never have out-of-date documentation again! 
- How comment-based help benefits from platyPS.

As a bonus we will talk about few advanced topics that haven’t been widely discussed before:

- support for multiple versions in a single file.
-localization story.

Come and join the movement to modernize the powershell help!

## Prerequisites

You can use any platform (Windows, macOS, Linux) and any PowerShell edition (Full, Core).
Not all feature of platyPS may be fully compatible with some old PowerShell versions.
For the full edition, v5.1 (latest) is recommended.

### Git

If you haven't use `git` before, please follow the [git basics](https://github.com/PowerShell/PowerShell/blob/48be62537933cf3ca3c9866f3acfa931acac2587/docs/git/basics.md) guide.

### GitHub

Please, register [GitHub account]( https://github.com/join) and set it up,
so you can push the code there.

### Markdown

If you haven't use markdown before, please read the [learn markdown in 60 seconds](http://commonmark.org/help/).


### PlatyPS

Install platyPS locally

```powershell
Install-Module -Scope CurrentUser platyPS
```

### AppVeyor

If you are not familiar with Continuous Integration or AppVeyor [here](http://ramblingcookiemonster.github.io/GitHub-Pester-AppVeyor/) is a great write-up by @ramblingcookiemonster.

## How to use

Clone the repo to your machine **before** the workshop.

```
git clone https://github.com/vors/psconfeu-2018-workshop
```

The workshop is broken down into the sections, you should follow them in order.
Every section is represented by `nn-SectionName.md` file that talks about the concepts and
walks you through the exercise to master them.
Every section assumes that your `pwd` is the root of the repo.

### [Start Here](https://github.com/vors/psconfeu-2018-workshop/blob/master/01-Bootstrap.md)
