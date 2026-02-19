---
document type: module
Help Version: 1.0.0.0
HelpInfoUri: 
Locale: en-US
Module Guid: 040757f4-ee7b-4e93-9883-f6a1930b6966
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: PSNotes Module
---

# PSNotes Module

## Description

PSNotes is a PowerShell module that provides a structured, versioned snippet and script library for reusable automation patterns. Create notes with aliases, tags, and metadata to quickly execute, copy, or preview commands. Organize notes into local or remote catalogs, search by name, tag, details, or snippet content, and turn frequently used automation into first-class commands.

## PSNotes

### [ConvertTo-Splatting](ConvertTo-Splatting.md)

Converts an existing PowerShell command into a splatting hashtable and splatted command.

### [Export-PSNote](Export-PSNote.md)

Exports PSNotes to a JSON file for backup or sharing.

### [Get-CommandSplatting](Get-CommandSplatting.md)

Generates a splatting template for a PowerShell command.

### [Get-PSNote](Get-PSNote.md)

Retrieves PSNotes from the note store by listing or searching.

### [Get-PSNoteAlias](Get-PSNoteAlias.md)

Resolves a PSNote by alias and outputs, copies, or executes its content.

### [Get-PSNoteMenu](Get-PSNoteMenu.md)

Displays an interactive, paged console menu for browsing and selecting PSNotes.

### [Get-RemoteCatalog](Get-RemoteCatalog.md)

Gets remote catalogs registered with PSNotes.

### [Import-PSNote](Import-PSNote.md)

Imports PSNotes from a JSON export file into the local note store.

### [Import-RemoteCatalog](Import-RemoteCatalog.md)

Registers a remote PSNotes catalog or imports it as a local catalog.

### [Initialize-PSNoteStore](Initialize-PSNoteStore.md)

Initializes the PSNotes store and required supporting files.

### [Move-PSNote](Move-PSNote.md)

Moves one or more PSNotes to a different catalog.

### [New-PSNote](New-PSNote.md)

Creates a new PSNote for storing reusable snippets or script references.

### [Remove-PSNote](Remove-PSNote.md)

Removes one or more PSNotes from the note store.

### [Remove-RemoteCatalog](Remove-RemoteCatalog.md)

Removes a remote catalog registration from PSNotes.

### [Set-PSNote](Set-PSNote.md)

Updates an existing PSNote or creates it if it does not already exist.

### [Update-PSNoteStore](Update-PSNoteStore.md)

Updates PSNotes catalogs to the latest format.

