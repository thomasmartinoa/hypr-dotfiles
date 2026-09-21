{
    "name": "Hypr Theme",
    "$schema": "vscode://schemas/color-theme",
    "type": "{{ mode }}",
    "semanticHighlighting": true,
    "semanticTokenColors": {
        "parameter": "{{ aqua }}",
        "parameter.declaration": "{{ aqua }}",
        "variable": "{{ fg }}",
        "variable.declaration": "{{ fg }}",
        "variable.readonly": "{{ color11 }}",
        "variable.defaultLibrary": "{{ fg }}",
        "property": "{{ aqua }}",
        "property.declaration": "{{ aqua }}",
        "property.readonly": "{{ aqua }}",
        "function": "{{ blue }}",
        "function.declaration": "{{ blue }}",
        "function.defaultLibrary": "{{ aqua }}",
        "method": "{{ blue }}",
        "method.declaration": "{{ blue }}",
        "class": "{{ yellow }}",
        "class.declaration": "{{ yellow }}",
        "class.defaultLibrary": "{{ yellow }}",
        "interface": "{{ yellow }}",
        "interface.declaration": "{{ yellow }}",
        "enum": "{{ yellow }}",
        "enumMember": "{{ orange }}",
        "type": "{{ yellow }}",
        "type.declaration": "{{ yellow }}",
        "type.defaultLibrary": "{{ fg }}",
        "typeParameter": "{{ yellow }}",
        "namespace": "{{ blue }}",
        "macro": "{{ aqua }}",
        "decorator": "{{ blue }}",
        "string": "{{ green }}",
        "number": "{{ orange }}",
        "boolean": "{{ orange }}",
        "regexp": "{{ color14 }}",
        "operator": "{{ color12 }}",
        "keyword": "{{ color13 }}",
        "comment": {"foreground": "{{ accent_dim }}", "fontStyle": "italic"},
        "comment.documentation": {"foreground": "{{ accent_dim }}", "fontStyle": "italic"}
    },
    "colors": {
        "foreground": "{{ fg }}",
        "disabledForeground": "{{ accent_mid }}",
        "focusBorder": "{{ accent_light }}80",
        "widget.shadow": "{{ bg0 }}80",
        "selection.background": "{{ selection_background }}80",
        "descriptionForeground": "{{ accent_dim }}",
        "errorForeground": "{{ red }}",
        "icon.foreground": "{{ fg }}",
        "sash.hoverBorder": "{{ accent_light }}",

        "textBlockQuote.background": "{{ bg0 }}",
        "textBlockQuote.border": "{{ accent_light }}",
        "textCodeBlock.background": "{{ bg0 }}",
        "textLink.activeForeground": "{{ color12 }}",
        "textLink.foreground": "{{ blue }}",
        "textPreformat.foreground": "{{ aqua }}",
        "textPreformat.background": "{{ bg0 }}",
        "textSeparator.foreground": "{{ accent_dim }}",

        "toolbar.hoverBackground": "{{ bg0 }}",
        "toolbar.activeBackground": "{{ accent_dim }}",

        "button.background": "{{ accent_light }}",
        "button.foreground": "{{ bg0 }}",
        "button.hoverBackground": "{{ blue }}",
        "button.secondaryForeground": "{{ fg }}",
        "button.secondaryBackground": "{{ accent_dim }}",
        "button.secondaryHoverBackground": "{{ bg0 }}",
        "button.border": "{{ accent_light }}20",
        "checkbox.background": "{{ bg0 }}",
        "checkbox.foreground": "{{ fg }}",
        "checkbox.border": "{{ accent_dim }}",
        "checkbox.selectBackground": "{{ accent_light }}",
        "checkbox.selectBorder": "{{ accent_light }}",

        "dropdown.background": "{{ bg0 }}",
        "dropdown.listBackground": "{{ bg0 }}",
        "dropdown.border": "{{ accent_dim }}",
        "dropdown.foreground": "{{ fg }}",

        "input.background": "{{ bg0 }}",
        "input.border": "{{ accent_dim }}",
        "input.foreground": "{{ fg }}",
        "input.placeholderForeground": "{{ accent_dim }}",
        "inputOption.activeBackground": "{{ accent_light }}40",
        "inputOption.activeBorder": "{{ accent_light }}",
        "inputOption.activeForeground": "{{ fg }}",
        "inputOption.hoverBackground": "{{ accent_dim }}",
        "inputValidation.errorBackground": "{{ red }}20",
        "inputValidation.errorForeground": "{{ red }}",
        "inputValidation.errorBorder": "{{ red }}",
        "inputValidation.infoBackground": "{{ blue }}20",
        "inputValidation.infoForeground": "{{ blue }}",
        "inputValidation.infoBorder": "{{ blue }}",
        "inputValidation.warningBackground": "{{ yellow }}20",
        "inputValidation.warningForeground": "{{ yellow }}",
        "inputValidation.warningBorder": "{{ yellow }}",

        "scrollbar.shadow": "{{ bg0 }}",
        "scrollbarSlider.activeBackground": "{{ accent_light }}80",
        "scrollbarSlider.background": "{{ accent_dim }}40",
        "scrollbarSlider.hoverBackground": "{{ accent_dim }}80",

        "badge.background": "{{ accent_light }}",
        "badge.foreground": "{{ bg0 }}",

        "progressBar.background": "{{ accent_light }}",

        "list.activeSelectionBackground": "{{ accent_light }}30",
        "list.activeSelectionForeground": "{{ fg }}",
        "list.activeSelectionIconForeground": "{{ fg }}",
        "list.dropBackground": "{{ accent_light }}20",
        "list.focusBackground": "{{ accent_light }}20",
        "list.focusForeground": "{{ fg }}",
        "list.focusOutline": "{{ accent_light }}60",
        "list.highlightForeground": "{{ accent_light }}",
        "list.hoverBackground": "{{ bg0 }}",
        "list.hoverForeground": "{{ fg }}",
        "list.inactiveSelectionBackground": "{{ accent_dim }}40",
        "list.inactiveSelectionForeground": "{{ fg }}",
        "list.inactiveFocusBackground": "{{ accent_dim }}40",
        "list.inactiveFocusOutline": "{{ accent_dim }}",
        "list.invalidItemForeground": "{{ red }}",
        "list.errorForeground": "{{ red }}",
        "list.warningForeground": "{{ yellow }}",
        "listFilterWidget.background": "{{ bg0 }}",
        "listFilterWidget.outline": "{{ accent_light }}",
        "listFilterWidget.noMatchesOutline": "{{ red }}",
        "list.filterMatchBackground": "{{ accent_light }}30",
        "list.filterMatchBorder": "{{ accent_light }}",
        "tree.indentGuidesStroke": "{{ accent_dim }}",
        "tree.inactiveIndentGuidesStroke": "{{ accent_dim }}60",
        "tree.tableColumnsBorder": "{{ accent_dim }}",
        "tree.tableOddRowsBackground": "{{ bg0 }}40",

        "activityBar.background": "{{ bg0 }}",
        "activityBar.dropBorder": "{{ accent_light }}",
        "activityBar.foreground": "{{ fg }}",
        "activityBar.inactiveForeground": "{{ accent_dim }}",
        "activityBar.border": "{{ bg0 }}",
        "activityBarBadge.background": "{{ accent_light }}",
        "activityBarBadge.foreground": "{{ bg0 }}",
        "activityBar.activeBorder": "{{ accent_light }}",
        "activityBar.activeBackground": "{{ bg0 }}40",

        "sideBar.background": "{{ bg0 }}",
        "sideBar.foreground": "{{ fg }}",
        "sideBar.border": "{{ bg0 }}",
        "sideBar.dropBackground": "{{ accent_light }}20",
        "sideBarTitle.foreground": "{{ fg }}",
        "sideBarSectionHeader.background": "{{ bg0 }}",
        "sideBarSectionHeader.foreground": "{{ fg }}",
        "sideBarSectionHeader.border": "{{ accent_dim }}40",

        "minimap.findMatchHighlight": "{{ accent_light }}80",
        "minimap.selectionHighlight": "{{ accent_light }}60",
        "minimap.errorHighlight": "{{ red }}",
        "minimap.warningHighlight": "{{ yellow }}",
        "minimap.background": "{{ bg0 }}",
        "minimap.selectionOccurrenceHighlight": "{{ accent_light }}40",
        "minimap.foregroundOpacity": "{{ bg0 }}c0",
        "minimapSlider.background": "{{ accent_dim }}20",
        "minimapSlider.hoverBackground": "{{ accent_dim }}40",
        "minimapSlider.activeBackground": "{{ accent_dim }}60",
        "minimapGutter.addedBackground": "{{ added }}",
        "minimapGutter.modifiedBackground": "{{ modified }}",
        "minimapGutter.deletedBackground": "{{ deleted }}",

        "editorGroup.border": "{{ accent_dim }}40",
        "editorGroup.dropBackground": "{{ accent_light }}20",
        "editorGroup.dropIntoPromptForeground": "{{ fg }}",
        "editorGroup.dropIntoPromptBackground": "{{ bg0 }}",
        "editorGroup.dropIntoPromptBorder": "{{ accent_light }}",
        "editorGroupHeader.noTabsBackground": "{{ bg0 }}",
        "editorGroupHeader.tabsBackground": "{{ bg0 }}",
        "editorGroupHeader.tabsBorder": "{{ bg0 }}",
        "editorGroupHeader.border": "{{ bg0 }}",
        "editorGroup.emptyBackground": "{{ bg0 }}",
        "tab.activeBackground": "{{ bg0 }}",
        "tab.unfocusedActiveBackground": "{{ bg0 }}",
        "tab.activeForeground": "{{ fg }}",
        "tab.activeBorder": "{{ accent_light }}",
        "tab.activeBorderTop": "{{ accent_light }}",
        "tab.unfocusedActiveBorder": "{{ accent_dim }}",
        "tab.unfocusedActiveBorderTop": "{{ accent_dim }}",
        "tab.border": "{{ bg0 }}",
        "tab.inactiveBackground": "{{ bg0 }}",
        "tab.inactiveForeground": "{{ accent_dim }}",
        "tab.unfocusedActiveForeground": "{{ fg }}",
        "tab.unfocusedInactiveForeground": "{{ accent_dim }}",
        "tab.hoverBackground": "{{ accent_dim }}40",
        "tab.unfocusedHoverBackground": "{{ accent_dim }}40",
        "tab.hoverForeground": "{{ fg }}",
        "tab.hoverBorder": "{{ accent_light }}40",
        "tab.activeModifiedBorder": "{{ yellow }}",
        "tab.inactiveModifiedBorder": "{{ yellow }}80",
        "tab.unfocusedActiveModifiedBorder": "{{ yellow }}80",
        "tab.unfocusedInactiveModifiedBorder": "{{ yellow }}60",
        "tab.lastPinnedBorder": "{{ accent_dim }}",
        "editorPane.background": "{{ bg0 }}",

        "editor.background": "{{ bg0 }}",
        "editor.foreground": "{{ fg }}",
        "editorLineNumber.foreground": "{{ accent_dim }}",
        "editorLineNumber.activeForeground": "{{ fg }}",
        "editorLineNumber.dimmedForeground": "{{ accent_dim }}80",
        "editorCursor.background": "{{ bg0 }}",
        "editorCursor.foreground": "{{ color15 }}",
        "editor.selectionBackground": "{{ selection_background }}60",
        "editor.selectionForeground": "{{ selection_foreground }}",
        "editor.inactiveSelectionBackground": "{{ selection_background }}30",
        "editor.selectionHighlightBackground": "{{ accent_light }}20",
        "editor.selectionHighlightBorder": "{{ accent_light }}40",
        "editor.wordHighlightBackground": "{{ accent_light }}20",
        "editor.wordHighlightBorder": "{{ accent_light }}40",
        "editor.wordHighlightStrongBackground": "{{ accent_light }}30",
        "editor.wordHighlightStrongBorder": "{{ accent_light }}60",
        "editor.wordHighlightTextBackground": "{{ accent_light }}15",
        "editor.wordHighlightTextBorder": "{{ accent_light }}30",
        "editor.findMatchBackground": "{{ yellow }}40",
        "editor.findMatchBorder": "{{ yellow }}",
        "editor.findMatchHighlightBackground": "{{ yellow }}25",
        "editor.findMatchHighlightBorder": "{{ yellow }}60",
        "editor.findRangeHighlightBackground": "{{ accent_light }}15",
        "editor.findRangeHighlightBorder": "{{ accent_light }}30",
        "searchEditor.findMatchBackground": "{{ yellow }}40",
        "searchEditor.findMatchBorder": "{{ yellow }}",
        "editor.hoverHighlightBackground": "{{ accent_light }}20",
        "editor.lineHighlightBackground": "{{ bg0 }}60",
        "editor.lineHighlightBorder": "{{ bg0 }}00",
        "editorLink.activeForeground": "{{ blue }}",
        "editor.rangeHighlightBackground": "{{ accent_light }}10",
        "editor.rangeHighlightBorder": "{{ accent_light }}20",
        "editor.symbolHighlightBackground": "{{ accent_light }}20",
        "editor.symbolHighlightBorder": "{{ accent_light }}40",
        "editorWhitespace.foreground": "{{ accent_dim }}60",
        "editorIndentGuide.background1": "{{ accent_dim }}30",
        "editorIndentGuide.background2": "{{ accent_dim }}30",
        "editorIndentGuide.background3": "{{ accent_dim }}30",
        "editorIndentGuide.background4": "{{ accent_dim }}30",
        "editorIndentGuide.background5": "{{ accent_dim }}30",
        "editorIndentGuide.background6": "{{ accent_dim }}30",
        "editorIndentGuide.activeBackground1": "{{ accent_dim }}80",
        "editorIndentGuide.activeBackground2": "{{ accent_dim }}80",
        "editorIndentGuide.activeBackground3": "{{ accent_dim }}80",
        "editorIndentGuide.activeBackground4": "{{ accent_dim }}80",
        "editorIndentGuide.activeBackground5": "{{ accent_dim }}80",
        "editorIndentGuide.activeBackground6": "{{ accent_dim }}80",
        "editorInlayHint.background": "{{ accent_dim }}30",
        "editorInlayHint.foreground": "{{ accent_dim }}",
        "editorInlayHint.typeBackground": "{{ yellow }}15",
        "editorInlayHint.typeForeground": "{{ yellow }}",
        "editorInlayHint.parameterBackground": "{{ color13 }}15",
        "editorInlayHint.parameterForeground": "{{ color13 }}",
        "editorRuler.foreground": "{{ accent_dim }}40",
        "editorCodeLens.foreground": "{{ accent_dim }}",
        "editorLightBulb.foreground": "{{ yellow }}",
        "editorLightBulbAutoFix.foreground": "{{ green }}",
        "editorLightBulbAi.foreground": "{{ purple }}",
        "editorBracketMatch.background": "{{ accent_light }}30",
        "editorBracketMatch.border": "{{ accent_light }}",
        "editorBracketHighlight.foreground1": "{{ blue }}",
        "editorBracketHighlight.foreground2": "{{ yellow }}",
        "editorBracketHighlight.foreground3": "{{ green }}",
        "editorBracketHighlight.foreground4": "{{ aqua }}",
        "editorBracketHighlight.foreground5": "{{ purple }}",
        "editorBracketHighlight.foreground6": "{{ orange }}",
        "editorBracketHighlight.unexpectedBracket.foreground": "{{ red }}",
        "editorBracketPairGuide.activeBackground1": "{{ blue }}60",
        "editorBracketPairGuide.activeBackground2": "{{ yellow }}60",
        "editorBracketPairGuide.activeBackground3": "{{ green }}60",
        "editorBracketPairGuide.activeBackground4": "{{ aqua }}60",
        "editorBracketPairGuide.activeBackground5": "{{ purple }}60",
        "editorBracketPairGuide.activeBackground6": "{{ orange }}60",
        "editorBracketPairGuide.background1": "{{ blue }}30",
        "editorBracketPairGuide.background2": "{{ yellow }}30",
        "editorBracketPairGuide.background3": "{{ green }}30",
        "editorBracketPairGuide.background4": "{{ aqua }}30",
        "editorBracketPairGuide.background5": "{{ purple }}30",
        "editorBracketPairGuide.background6": "{{ orange }}30",
        "editorOverviewRuler.background": "{{ bg0 }}",
        "editorOverviewRuler.border": "{{ accent_dim }}20",
        "editorOverviewRuler.findMatchForeground": "{{ yellow }}80",
        "editorOverviewRuler.rangeHighlightForeground": "{{ accent_light }}60",
        "editorOverviewRuler.selectionHighlightForeground": "{{ accent_light }}80",
        "editorOverviewRuler.wordHighlightForeground": "{{ accent_light }}60",
        "editorOverviewRuler.wordHighlightStrongForeground": "{{ accent_light }}80",
        "editorOverviewRuler.wordHighlightTextForeground": "{{ accent_light }}40",
        "editorOverviewRuler.modifiedForeground": "{{ modified }}80",
        "editorOverviewRuler.addedForeground": "{{ added }}80",
        "editorOverviewRuler.deletedForeground": "{{ deleted }}80",
        "editorOverviewRuler.errorForeground": "{{ red }}",
        "editorOverviewRuler.warningForeground": "{{ yellow }}",
        "editorOverviewRuler.infoForeground": "{{ blue }}",
        "editorOverviewRuler.bracketMatchForeground": "{{ accent_light }}",
        "editorError.foreground": "{{ red }}",
        "editorError.background": "{{ red }}15",
        "editorError.border": "{{ red }}00",
        "editorWarning.foreground": "{{ yellow }}",
        "editorWarning.background": "{{ yellow }}15",
        "editorWarning.border": "{{ yellow }}00",
        "editorInfo.foreground": "{{ blue }}",
        "editorInfo.background": "{{ blue }}15",
        "editorInfo.border": "{{ blue }}00",
        "editorHint.foreground": "{{ aqua }}",
        "editorHint.border": "{{ aqua }}00",
        "problemsErrorIcon.foreground": "{{ red }}",
        "problemsWarningIcon.foreground": "{{ yellow }}",
        "problemsInfoIcon.foreground": "{{ blue }}",
        "editorUnnecessaryCode.opacity": "{{ bg0 }}80",
        "editorUnnecessaryCode.border": "{{ accent_dim }}",
        "editorGutter.background": "{{ bg0 }}",
        "editorGutter.modifiedBackground": "{{ modified }}",
        "editorGutter.addedBackground": "{{ added }}",
        "editorGutter.deletedBackground": "{{ deleted }}",
        "editorGutter.commentRangeForeground": "{{ accent_dim }}",
        "editorGutter.commentGlyphForeground": "{{ accent_light }}",
        "editorGutter.commentUnresolvedGlyphForeground": "{{ yellow }}",
        "editorGutter.foldingControlForeground": "{{ accent_dim }}",
        "editorCommentsWidget.resolvedBorder": "{{ green }}",
        "editorCommentsWidget.unresolvedBorder": "{{ yellow }}",
        "editorCommentsWidget.rangeBackground": "{{ accent_light }}10",
        "editorCommentsWidget.rangeActiveBackground": "{{ accent_light }}20",

        "diffEditor.insertedTextBackground": "{{ added }}20",
        "diffEditor.insertedTextBorder": "{{ added }}00",
        "diffEditor.removedTextBackground": "{{ deleted }}20",
        "diffEditor.removedTextBorder": "{{ deleted }}00",
        "diffEditor.insertedLineBackground": "{{ added }}15",
        "diffEditor.removedLineBackground": "{{ deleted }}15",
        "diffEditorGutter.insertedLineBackground": "{{ green }}30",
        "diffEditorGutter.removedLineBackground": "{{ red }}30",
        "diffEditorOverview.insertedForeground": "{{ green }}80",
        "diffEditorOverview.removedForeground": "{{ red }}80",
        "diffEditor.diagonalFill": "{{ accent_dim }}30",
        "diffEditor.unchangedRegionBackground": "{{ bg0 }}",
        "diffEditor.unchangedRegionForeground": "{{ accent_dim }}",
        "diffEditor.unchangedCodeBackground": "{{ bg0 }}40",
        "diffEditor.move.border": "{{ aqua }}80",
        "diffEditor.moveActive.border": "{{ aqua }}",

        "editorWidget.foreground": "{{ fg }}",
        "editorWidget.background": "{{ bg0 }}",
        "editorWidget.border": "{{ accent_dim }}",
        "editorWidget.resizeBorder": "{{ accent_light }}",
        "editorSuggestWidget.background": "{{ bg0 }}",
        "editorSuggestWidget.border": "{{ accent_dim }}",
        "editorSuggestWidget.foreground": "{{ fg }}",
        "editorSuggestWidget.focusHighlightForeground": "{{ accent_light }}",
        "editorSuggestWidget.highlightForeground": "{{ accent_light }}",
        "editorSuggestWidget.selectedBackground": "{{ accent_light }}30",
        "editorSuggestWidget.selectedForeground": "{{ fg }}",
        "editorSuggestWidget.selectedIconForeground": "{{ fg }}",
        "editorSuggestWidgetStatus.foreground": "{{ accent_dim }}",
        "editorHoverWidget.foreground": "{{ fg }}",
        "editorHoverWidget.background": "{{ bg0 }}",
        "editorHoverWidget.border": "{{ accent_dim }}",
        "editorHoverWidget.highlightForeground": "{{ accent_light }}",
        "editorHoverWidget.statusBarBackground": "{{ accent_dim }}30",
        "editorGhostText.foreground": "{{ accent_dim }}",
        "editorGhostText.background": "{{ accent_dim }}10",
        "editorGhostText.border": "{{ accent_dim }}00",
        "editorStickyScroll.background": "{{ bg0 }}",
        "editorStickyScrollHover.background": "{{ accent_dim }}40",
        "debugExceptionWidget.background": "{{ red }}20",
        "debugExceptionWidget.border": "{{ red }}",
        "editorMarkerNavigation.background": "{{ bg0 }}",
        "editorMarkerNavigationError.background": "{{ red }}20",
        "editorMarkerNavigationError.headerBackground": "{{ red }}15",
        "editorMarkerNavigationWarning.background": "{{ yellow }}20",
        "editorMarkerNavigationWarning.headerBackground": "{{ yellow }}15",
        "editorMarkerNavigationInfo.background": "{{ blue }}20",
        "editorMarkerNavigationInfo.headerBackground": "{{ blue }}15",

        "peekView.border": "{{ accent_light }}",
        "peekViewEditor.background": "{{ bg0 }}",
        "peekViewEditorGutter.background": "{{ bg0 }}",
        "peekViewEditor.matchHighlightBackground": "{{ yellow }}30",
        "peekViewEditor.matchHighlightBorder": "{{ yellow }}",
        "peekViewResult.background": "{{ bg0 }}",
        "peekViewResult.fileForeground": "{{ fg }}",
        "peekViewResult.lineForeground": "{{ accent_dim }}",
        "peekViewResult.matchHighlightBackground": "{{ yellow }}30",
        "peekViewResult.selectionBackground": "{{ accent_light }}30",
        "peekViewResult.selectionForeground": "{{ fg }}",
        "peekViewTitle.background": "{{ bg0 }}",
        "peekViewTitleDescription.foreground": "{{ accent_dim }}",
        "peekViewTitleLabel.foreground": "{{ fg }}",

        "merge.currentContentBackground": "{{ aqua }}20",
        "merge.currentHeaderBackground": "{{ aqua }}40",
        "merge.incomingContentBackground": "{{ green }}20",
        "merge.incomingHeaderBackground": "{{ green }}40",
        "merge.commonContentBackground": "{{ accent_dim }}20",
        "merge.commonHeaderBackground": "{{ accent_dim }}40",
        "merge.border": "{{ accent_dim }}",
        "editorOverviewRuler.currentContentForeground": "{{ aqua }}",
        "editorOverviewRuler.incomingContentForeground": "{{ green }}",
        "editorOverviewRuler.commonContentForeground": "{{ accent_dim }}",
        "mergeEditor.change.background": "{{ accent_light }}15",
        "mergeEditor.change.word.background": "{{ accent_light }}30",
        "mergeEditor.conflict.handledUnfocused.border": "{{ green }}80",
        "mergeEditor.conflict.handled.minimapOverViewRuler": "{{ green }}",
        "mergeEditor.conflict.unhandledUnfocused.border": "{{ yellow }}80",
        "mergeEditor.conflict.unhandled.minimapOverViewRuler": "{{ yellow }}",
        "mergeEditor.conflictingLines.background": "{{ yellow }}15",
        "mergeEditor.changeBase.background": "{{ accent_dim }}20",
        "mergeEditor.changeBase.word.background": "{{ accent_dim }}40",

        "panel.background": "{{ bg0 }}",
        "panel.border": "{{ accent_dim }}40",
        "panel.dropBorder": "{{ accent_light }}",
        "panelTitle.activeBorder": "{{ accent_light }}",
        "panelTitle.activeForeground": "{{ fg }}",
        "panelTitle.inactiveForeground": "{{ accent_dim }}",
        "panelInput.border": "{{ accent_dim }}",
        "panelSection.border": "{{ accent_dim }}40",
        "panelSection.dropBackground": "{{ accent_light }}20",
        "panelSectionHeader.background": "{{ bg0 }}",
        "panelSectionHeader.foreground": "{{ fg }}",
        "panelSectionHeader.border": "{{ accent_dim }}40",

        "outputView.background": "{{ bg0 }}",
        "outputViewStickyScroll.background": "{{ bg0 }}",

        "statusBar.background": "{{ bg0 }}",
        "statusBar.foreground": "{{ fg }}",
        "statusBar.border": "{{ bg0 }}",
        "statusBar.debuggingBackground": "{{ yellow }}",
        "statusBar.debuggingForeground": "{{ bg0 }}",
        "statusBar.debuggingBorder": "{{ yellow }}",
        "statusBar.noFolderBackground": "{{ bg0 }}",
        "statusBar.noFolderForeground": "{{ fg }}",
        "statusBar.noFolderBorder": "{{ bg0 }}",
        "statusBar.focusBorder": "{{ accent_light }}",
        "statusBarItem.activeBackground": "{{ accent_dim }}",
        "statusBarItem.hoverBackground": "{{ accent_dim }}60",
        "statusBarItem.hoverForeground": "{{ fg }}",
        "statusBarItem.prominentForeground": "{{ fg }}",
        "statusBarItem.prominentBackground": "{{ accent_light }}",
        "statusBarItem.prominentHoverBackground": "{{ accent_light }}80",
        "statusBarItem.remoteBackground": "{{ accent_light }}",
        "statusBarItem.remoteForeground": "{{ bg0 }}",
        "statusBarItem.remoteHoverBackground": "{{ accent_light }}80",
        "statusBarItem.errorBackground": "{{ red }}",
        "statusBarItem.errorForeground": "{{ bg0 }}",
        "statusBarItem.errorHoverBackground": "{{ red }}80",
        "statusBarItem.warningBackground": "{{ yellow }}",
        "statusBarItem.warningForeground": "{{ bg0 }}",
        "statusBarItem.warningHoverBackground": "{{ yellow }}80",
        "statusBarItem.compactHoverBackground": "{{ accent_dim }}",
        "statusBarItem.focusBorder": "{{ accent_light }}",

        "titleBar.activeBackground": "{{ bg0 }}",
        "titleBar.activeForeground": "{{ fg }}",
        "titleBar.inactiveBackground": "{{ bg0 }}",
        "titleBar.inactiveForeground": "{{ accent_dim }}",
        "titleBar.border": "{{ bg0 }}",

        "menubar.selectionForeground": "{{ fg }}",
        "menubar.selectionBackground": "{{ accent_light }}30",
        "menubar.selectionBorder": "{{ accent_light }}00",
        "menu.foreground": "{{ fg }}",
        "menu.background": "{{ bg0 }}",
        "menu.selectionForeground": "{{ fg }}",
        "menu.selectionBackground": "{{ accent_light }}30",
        "menu.selectionBorder": "{{ accent_light }}00",
        "menu.separatorBackground": "{{ accent_dim }}",
        "menu.border": "{{ accent_dim }}",

        "commandCenter.foreground": "{{ fg }}",
        "commandCenter.activeForeground": "{{ fg }}",
        "commandCenter.background": "{{ bg0 }}",
        "commandCenter.activeBackground": "{{ accent_dim }}",
        "commandCenter.border": "{{ accent_dim }}",
        "commandCenter.inactiveForeground": "{{ accent_dim }}",
        "commandCenter.inactiveBorder": "{{ accent_dim }}",
        "commandCenter.activeBorder": "{{ accent_light }}",
        "commandCenter.debuggingBackground": "{{ yellow }}20",

        "notificationCenter.border": "{{ accent_dim }}",
        "notificationCenterHeader.foreground": "{{ fg }}",
        "notificationCenterHeader.background": "{{ bg0 }}",
        "notificationToast.border": "{{ accent_dim }}",
        "notifications.foreground": "{{ fg }}",
        "notifications.background": "{{ bg0 }}",
        "notifications.border": "{{ accent_dim }}",
        "notificationLink.foreground": "{{ accent_light }}",
        "notificationsErrorIcon.foreground": "{{ red }}",
        "notificationsWarningIcon.foreground": "{{ yellow }}",
        "notificationsInfoIcon.foreground": "{{ blue }}",

        "banner.background": "{{ accent_light }}20",
        "banner.foreground": "{{ fg }}",
        "banner.iconForeground": "{{ accent_light }}",

        "extensionButton.prominentBackground": "{{ accent_light }}",
        "extensionButton.prominentForeground": "{{ bg0 }}",
        "extensionButton.prominentHoverBackground": "{{ accent_light }}80",
        "extensionButton.background": "{{ accent_dim }}",
        "extensionButton.foreground": "{{ fg }}",
        "extensionButton.hoverBackground": "{{ accent_dim }}80",
        "extensionButton.separator": "{{ bg0 }}",
        "extensionBadge.remoteBackground": "{{ accent_light }}",
        "extensionBadge.remoteForeground": "{{ bg0 }}",
        "extensionIcon.starForeground": "{{ yellow }}",
        "extensionIcon.verifiedForeground": "{{ aqua }}",
        "extensionIcon.preReleaseForeground": "{{ yellow }}",
        "extensionIcon.sponsorForeground": "{{ purple }}",

        "pickerGroup.border": "{{ accent_dim }}",
        "pickerGroup.foreground": "{{ accent_light }}",
        "quickInput.background": "{{ bg0 }}",
        "quickInput.foreground": "{{ fg }}",
        "quickInputList.focusBackground": "{{ accent_light }}30",
        "quickInputList.focusForeground": "{{ fg }}",
        "quickInputList.focusIconForeground": "{{ fg }}",
        "quickInputTitle.background": "{{ bg0 }}",

        "keybindingLabel.background": "{{ accent_dim }}40",
        "keybindingLabel.foreground": "{{ fg }}",
        "keybindingLabel.border": "{{ accent_dim }}",
        "keybindingLabel.bottomBorder": "{{ accent_dim }}",
        "keybindingTable.headerBackground": "{{ bg0 }}",
        "keybindingTable.rowsBackground": "{{ bg0 }}40",

        "terminal.background": "{{ bg0 }}",
        "terminal.foreground": "{{ fg }}",
        "terminal.border": "{{ accent_dim }}40",
        "terminal.selectionBackground": "{{ selection_background }}60",
        "terminal.selectionForeground": "{{ selection_foreground }}",
        "terminal.inactiveSelectionBackground": "{{ selection_background }}30",
        "terminal.findMatchBackground": "{{ yellow }}40",
        "terminal.findMatchBorder": "{{ yellow }}",
        "terminal.findMatchHighlightBackground": "{{ yellow }}25",
        "terminal.findMatchHighlightBorder": "{{ yellow }}60",
        "terminal.hoverHighlightBackground": "{{ accent_light }}20",
        "terminalCursor.background": "{{ bg0 }}",
        "terminalCursor.foreground": "{{ color15 }}",
        "terminal.ansiBlack": "{{ bg0 }}",
        "terminal.ansiRed": "{{ red }}",
        "terminal.ansiGreen": "{{ green }}",
        "terminal.ansiYellow": "{{ yellow }}",
        "terminal.ansiBlue": "{{ blue }}",
        "terminal.ansiMagenta": "{{ purple }}",
        "terminal.ansiCyan": "{{ aqua }}",
        "terminal.ansiWhite": "{{ fg }}",
        "terminal.ansiBrightBlack": "{{ accent_dim }}",
        "terminal.ansiBrightRed": "{{ color9 }}",
        "terminal.ansiBrightGreen": "{{ color10 }}",
        "terminal.ansiBrightYellow": "{{ color11 }}",
        "terminal.ansiBrightBlue": "{{ color12 }}",
        "terminal.ansiBrightMagenta": "{{ color13 }}",
        "terminal.ansiBrightCyan": "{{ color14 }}",
        "terminal.ansiBrightWhite": "{{ color15 }}",
        "terminal.tab.activeBorder": "{{ accent_light }}",
        "terminalCommandDecoration.defaultBackground": "{{ accent_dim }}",
        "terminalCommandDecoration.successBackground": "{{ green }}",
        "terminalCommandDecoration.errorBackground": "{{ red }}",
        "terminalOverviewRuler.cursorForeground": "{{ color15 }}",
        "terminalOverviewRuler.findMatchForeground": "{{ yellow }}",
        "terminalStickyScroll.background": "{{ bg0 }}",
        "terminalStickyScrollHover.background": "{{ accent_dim }}40",

        "debugToolBar.background": "{{ bg0 }}",
        "debugToolBar.border": "{{ accent_dim }}",
        "debugView.stateLabelForeground": "{{ fg }}",
        "debugView.stateLabelBackground": "{{ accent_light }}30",
        "debugView.valueChangedHighlight": "{{ aqua }}40",
        "debugView.exceptionLabelForeground": "{{ bg0 }}",
        "debugView.exceptionLabelBackground": "{{ red }}",
        "debugTokenExpression.name": "{{ purple }}",
        "debugTokenExpression.value": "{{ fg }}",
        "debugTokenExpression.string": "{{ green }}",
        "debugTokenExpression.boolean": "{{ orange }}",
        "debugTokenExpression.number": "{{ orange }}",
        "debugTokenExpression.error": "{{ red }}",

        "testing.iconFailed": "{{ red }}",
        "testing.iconErrored": "{{ red }}",
        "testing.iconPassed": "{{ green }}",
        "testing.runAction": "{{ green }}",
        "testing.iconQueued": "{{ yellow }}",
        "testing.iconUnset": "{{ accent_dim }}",
        "testing.iconSkipped": "{{ yellow }}",
        "testing.peekBorder": "{{ accent_light }}",
        "testing.peekHeaderBackground": "{{ bg0 }}",
        "testing.message.error.decorationForeground": "{{ red }}",
        "testing.message.error.lineBackground": "{{ red }}15",
        "testing.message.info.decorationForeground": "{{ blue }}",
        "testing.message.info.lineBackground": "{{ blue }}15",

        "welcomePage.background": "{{ bg0 }}",
        "welcomePage.tileBackground": "{{ bg0 }}",
        "welcomePage.tileHoverBackground": "{{ accent_dim }}40",
        "welcomePage.tileBorder": "{{ accent_dim }}",
        "welcomePage.progress.background": "{{ accent_dim }}",
        "welcomePage.progress.foreground": "{{ accent_light }}",
        "walkThrough.embeddedEditorBackground": "{{ bg0 }}",
        "walkthrough.stepTitle.foreground": "{{ fg }}",

        "gitDecoration.addedResourceForeground": "{{ added }}",
        "gitDecoration.modifiedResourceForeground": "{{ modified }}",
        "gitDecoration.deletedResourceForeground": "{{ deleted }}",
        "gitDecoration.renamedResourceForeground": "{{ renamed }}",
        "gitDecoration.stageModifiedResourceForeground": "{{ modified }}",
        "gitDecoration.stageDeletedResourceForeground": "{{ deleted }}",
        "gitDecoration.untrackedResourceForeground": "{{ added }}",
        "gitDecoration.ignoredResourceForeground": "{{ accent_dim }}",
        "gitDecoration.conflictingResourceForeground": "{{ conflict }}",
        "gitDecoration.submoduleResourceForeground": "{{ renamed }}",

        "settings.headerForeground": "{{ fg }}",
        "settings.modifiedItemIndicator": "{{ accent_light }}",
        "settings.dropdownBackground": "{{ bg0 }}",
        "settings.dropdownForeground": "{{ fg }}",
        "settings.dropdownBorder": "{{ accent_dim }}",
        "settings.dropdownListBorder": "{{ accent_dim }}",
        "settings.checkboxBackground": "{{ bg0 }}",
        "settings.checkboxForeground": "{{ fg }}",
        "settings.checkboxBorder": "{{ accent_dim }}",
        "settings.rowHoverBackground": "{{ bg0 }}",
        "settings.textInputBackground": "{{ bg0 }}",
        "settings.textInputForeground": "{{ fg }}",
        "settings.textInputBorder": "{{ accent_dim }}",
        "settings.numberInputBackground": "{{ bg0 }}",
        "settings.numberInputForeground": "{{ fg }}",
        "settings.numberInputBorder": "{{ accent_dim }}",
        "settings.focusedRowBackground": "{{ accent_light }}10",
        "settings.focusedRowBorder": "{{ accent_light }}40",
        "settings.headerBorder": "{{ accent_dim }}",
        "settings.sashBorder": "{{ accent_dim }}",
        "settings.settingsHeaderHoverForeground": "{{ accent_light }}",

        "breadcrumb.foreground": "{{ accent_dim }}",
        "breadcrumb.background": "{{ bg0 }}",
        "breadcrumb.focusForeground": "{{ fg }}",
        "breadcrumb.activeSelectionForeground": "{{ fg }}",
        "breadcrumbPicker.background": "{{ bg0 }}",

        "editor.snippetTabstopHighlightBackground": "{{ accent_light }}20",
        "editor.snippetTabstopHighlightBorder": "{{ accent_light }}40",
        "editor.snippetFinalTabstopHighlightBackground": "{{ green }}20",
        "editor.snippetFinalTabstopHighlightBorder": "{{ green }}40",

        "symbolIcon.arrayForeground": "{{ orange }}",
        "symbolIcon.booleanForeground": "{{ orange }}",
        "symbolIcon.classForeground": "{{ yellow }}",
        "symbolIcon.colorForeground": "{{ aqua }}",
        "symbolIcon.constantForeground": "{{ color11 }}",
        "symbolIcon.constructorForeground": "{{ blue }}",
        "symbolIcon.enumeratorForeground": "{{ yellow }}",
        "symbolIcon.enumeratorMemberForeground": "{{ orange }}",
        "symbolIcon.eventForeground": "{{ yellow }}",
        "symbolIcon.fieldForeground": "{{ fg }}",
        "symbolIcon.fileForeground": "{{ fg }}",
        "symbolIcon.folderForeground": "{{ fg }}",
        "symbolIcon.functionForeground": "{{ blue }}",
        "symbolIcon.interfaceForeground": "{{ yellow }}",
        "symbolIcon.keyForeground": "{{ color13 }}",
        "symbolIcon.keywordForeground": "{{ color13 }}",
        "symbolIcon.methodForeground": "{{ blue }}",
        "symbolIcon.moduleForeground": "{{ yellow }}",
        "symbolIcon.namespaceForeground": "{{ blue }}",
        "symbolIcon.nullForeground": "{{ orange }}",
        "symbolIcon.numberForeground": "{{ orange }}",
        "symbolIcon.objectForeground": "{{ yellow }}",
        "symbolIcon.operatorForeground": "{{ color12 }}",
        "symbolIcon.packageForeground": "{{ yellow }}",
        "symbolIcon.propertyForeground": "{{ fg }}",
        "symbolIcon.referenceForeground": "{{ color13 }}",
        "symbolIcon.snippetForeground": "{{ green }}",
        "symbolIcon.stringForeground": "{{ green }}",
        "symbolIcon.structForeground": "{{ yellow }}",
        "symbolIcon.textForeground": "{{ fg }}",
        "symbolIcon.typeParameterForeground": "{{ yellow }}",
        "symbolIcon.unitForeground": "{{ orange }}",
        "symbolIcon.variableForeground": "{{ color13 }}",

        "debugIcon.breakpointForeground": "{{ red }}",
        "debugIcon.breakpointDisabledForeground": "{{ accent_dim }}",
        "debugIcon.breakpointUnverifiedForeground": "{{ yellow }}",
        "debugIcon.breakpointCurrentStackframeForeground": "{{ yellow }}",
        "debugIcon.breakpointStackframeForeground": "{{ green }}",
        "debugIcon.startForeground": "{{ green }}",
        "debugIcon.pauseForeground": "{{ yellow }}",
        "debugIcon.stopForeground": "{{ red }}",
        "debugIcon.disconnectForeground": "{{ red }}",
        "debugIcon.restartForeground": "{{ green }}",
        "debugIcon.stepOverForeground": "{{ blue }}",
        "debugIcon.stepIntoForeground": "{{ aqua }}",
        "debugIcon.stepOutForeground": "{{ purple }}",
        "debugIcon.continueForeground": "{{ green }}",
        "debugIcon.stepBackForeground": "{{ yellow }}",
        "debugConsole.infoForeground": "{{ blue }}",
        "debugConsole.warningForeground": "{{ yellow }}",
        "debugConsole.errorForeground": "{{ red }}",
        "debugConsole.sourceForeground": "{{ fg }}",
        "debugConsoleInputIcon.foreground": "{{ accent_light }}",

        "notebook.editorBackground": "{{ bg0 }}",
        "notebook.cellBorderColor": "{{ accent_dim }}40",
        "notebook.cellHoverBackground": "{{ bg0 }}40",
        "notebook.cellInsertionIndicator": "{{ accent_light }}",
        "notebook.cellStatusBarItemHoverBackground": "{{ accent_dim }}",
        "notebook.cellToolbarSeparator": "{{ accent_dim }}",
        "notebook.cellEditorBackground": "{{ bg0 }}",
        "notebook.focusedCellBackground": "{{ bg0 }}60",
        "notebook.focusedCellBorder": "{{ accent_light }}",
        "notebook.focusedEditorBorder": "{{ accent_light }}",
        "notebook.inactiveFocusedCellBorder": "{{ accent_dim }}",
        "notebook.inactiveSelectedCellBorder": "{{ accent_dim }}",
        "notebook.outputContainerBackgroundColor": "{{ bg0 }}",
        "notebook.outputContainerBorderColor": "{{ accent_dim }}40",
        "notebook.selectedCellBackground": "{{ accent_light }}15",
        "notebook.selectedCellBorder": "{{ accent_light }}40",
        "notebook.symbolHighlightBackground": "{{ accent_light }}20",
        "notebookStatusErrorIcon.foreground": "{{ red }}",
        "notebookStatusRunningIcon.foreground": "{{ accent_light }}",
        "notebookStatusSuccessIcon.foreground": "{{ green }}",
        "notebookEditorOverviewRuler.runningCellForeground": "{{ accent_light }}",

        "charts.foreground": "{{ fg }}",
        "charts.lines": "{{ accent_dim }}",
        "charts.red": "{{ red }}",
        "charts.blue": "{{ blue }}",
        "charts.yellow": "{{ yellow }}",
        "charts.orange": "{{ orange }}",
        "charts.green": "{{ green }}",
        "charts.purple": "{{ purple }}",

        "ports.iconRunningProcessForeground": "{{ accent_light }}",

        "commentsView.resolvedIcon": "{{ green }}",
        "commentsView.unresolvedIcon": "{{ yellow }}",

        "editorWatermark.foreground": "{{ accent_dim }}",

        "inlineChat.background": "{{ bg0 }}",
        "inlineChat.border": "{{ accent_dim }}",
        "inlineChat.shadow": "{{ bg0 }}80",
        "inlineChatInput.border": "{{ accent_dim }}",
        "inlineChatInput.focusBorder": "{{ accent_light }}",
        "inlineChatInput.placeholderForeground": "{{ accent_dim }}",
        "inlineChatInput.background": "{{ bg0 }}",
        "inlineChatDiff.inserted": "{{ green }}20",
        "inlineChatDiff.removed": "{{ red }}20",

        "chat.requestBackground": "{{ bg0 }}",
        "chat.requestBorder": "{{ accent_dim }}"
    },
    "tokenColors": [
        {
            "name": "Comment",
            "scope": ["comment", "punctuation.definition.comment"],
            "settings": {
                "fontStyle": "italic",
                "foreground": "{{ accent_dim }}"
            }
        },
        {
            "name": "Variable",
            "scope": ["variable", "string constant.other.placeholder"],
            "settings": {
                "foreground": "{{ fg }}"
            }
        },
        {
            "name": "Variable Parameter",
            "scope": ["variable.parameter", "entity.name.variable.parameter", "meta.function.parameter"],
            "settings": {
                "foreground": "{{ aqua }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "Variable Property",
            "scope": ["variable.other.property", "variable.other.object.property"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "Variable Constant",
            "scope": ["variable.other.constant"],
            "settings": {
                "foreground": "{{ color11 }}"
            }
        },
        {
            "name": "Enum Member",
            "scope": ["variable.other.enummember"],
            "settings": {
                "foreground": "{{ orange }}"
            }
        },
        {
            "name": "Invalid",
            "scope": ["invalid", "invalid.illegal"],
            "settings": {
                "foreground": "{{ red }}",
                "fontStyle": "strikethrough"
            }
        },
        {
            "name": "Invalid Deprecated",
            "scope": ["invalid.deprecated"],
            "settings": {
                "foreground": "{{ yellow }}",
                "fontStyle": "strikethrough"
            }
        },
        {
            "name": "Keyword",
            "scope": ["keyword", "storage.type.class", "storage.type.function"],
            "settings": {
                "foreground": "{{ color13 }}"
            }
        },
        {
            "name": "Storage Modifier",
            "scope": ["storage.modifier"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "Keyword Control",
            "scope": ["keyword.control", "keyword.control.flow"],
            "settings": {
                "foreground": "{{ color13 }}"
            }
        },
        {
            "name": "Keyword Import",
            "scope": ["keyword.control.import", "keyword.control.export", "keyword.control.from", "keyword.control.as"],
            "settings": {
                "foreground": "{{ blue }}"
            }
        },
        {
            "name": "Keyword Operator",
            "scope": ["keyword.operator", "keyword.operator.new", "keyword.operator.expression", "keyword.operator.logical", "keyword.operator.comparison"],
            "settings": {
                "foreground": "{{ color12 }}"
            }
        },
        {
            "name": "Operator",
            "scope": ["punctuation.accessor", "punctuation.separator.key-value"],
            "settings": {
                "foreground": "{{ color12 }}"
            }
        },
        {
            "name": "Type",
            "scope": ["storage.type", "entity.name.type"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "Type Builtin",
            "scope": ["storage.type.primitive", "support.type"],
            "settings": {
                "foreground": "{{ fg }}"
            }
        },
        {
            "name": "Type Class",
            "scope": ["entity.name.type.class", "support.class", "entity.other.inherited-class"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "Type Interface",
            "scope": ["entity.name.type.interface"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "Type Enum",
            "scope": ["entity.name.type.enum"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "Type Parameter",
            "scope": ["entity.name.type.parameter"],
            "settings": {
                "foreground": "{{ yellow }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "Namespace",
            "scope": ["entity.name.namespace", "entity.name.type.module"],
            "settings": {
                "foreground": "{{ blue }}"
            }
        },
        {
            "name": "Function",
            "scope": ["entity.name.function", "meta.function-call.generic"],
            "settings": {
                "foreground": "{{ blue }}"
            }
        },
        {
            "name": "Function Builtin",
            "scope": ["support.function"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "Function Method",
            "scope": ["entity.name.function.method", "meta.method.declaration"],
            "settings": {
                "foreground": "{{ blue }}"
            }
        },
        {
            "name": "Function Decorator",
            "scope": ["entity.name.function.decorator", "meta.decorator", "punctuation.decorator"],
            "settings": {
                "foreground": "{{ aqua }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "Punctuation",
            "scope": ["punctuation", "meta.brace", "meta.bracket"],
            "settings": {
                "foreground": "{{ accent_mid }}"
            }
        },
        {
            "name": "Constant Numeric",
            "scope": ["constant.numeric", "constant.numeric.integer", "constant.numeric.float", "constant.numeric.hex", "constant.numeric.octal", "constant.numeric.binary"],
            "settings": {
                "foreground": "{{ orange }}"
            }
        },
        {
            "name": "Constant Boolean",
            "scope": ["constant.language.boolean"],
            "settings": {
                "foreground": "{{ orange }}"
            }
        },
        {
            "name": "Constant Builtin",
            "scope": ["constant.language", "constant.language.null", "constant.language.undefined"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "Constant Character",
            "scope": ["constant.character"],
            "settings": {
                "foreground": "{{ green }}"
            }
        },
        {
            "name": "Constant Character Escape",
            "scope": ["constant.character.escape"],
            "settings": {
                "foreground": "{{ color13 }}"
            }
        },
        {
            "name": "String",
            "scope": ["string", "string.quoted", "string.template"],
            "settings": {
                "foreground": "{{ green }}"
            }
        },
        {
            "name": "String Interpolation",
            "scope": ["punctuation.definition.template-expression", "punctuation.section.embedded", "meta.embedded.line"],
            "settings": {
                "foreground": "{{ color12 }}"
            }
        },
        {
            "name": "String Regexp",
            "scope": ["string.regexp", "constant.other.character-class.regexp", "constant.character.escape.regexp"],
            "settings": {
                "foreground": "{{ color14 }}"
            }
        },
        {
            "name": "Support",
            "scope": ["support.type.property-name", "support.constant"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "Tag",
            "scope": ["entity.name.tag", "meta.tag"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "Tag Attribute",
            "scope": ["entity.other.attribute-name"],
            "settings": {
                "foreground": "{{ fg }}"
            }
        },
        {
            "name": "CSS Property",
            "scope": ["support.type.property-name.css", "support.type.vendored.property-name.css", "meta.property-name.css"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "CSS Value",
            "scope": ["support.constant.property-value.css", "meta.property-value.css"],
            "settings": {
                "foreground": "{{ fg }}"
            }
        },
        {
            "name": "CSS Selector",
            "scope": ["entity.other.attribute-name.class.css", "entity.other.attribute-name.id.css"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "CSS Pseudo",
            "scope": ["entity.other.attribute-name.pseudo-class.css", "entity.other.attribute-name.pseudo-element.css"],
            "settings": {
                "foreground": "{{ aqua }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "CSS Units",
            "scope": ["keyword.other.unit.css"],
            "settings": {
                "foreground": "{{ orange }}"
            }
        },
        {
            "name": "JSON Key Level 0",
            "scope": ["source.json meta.structure.dictionary.json support.type.property-name.json"],
            "settings": {
                "foreground": "{{ orange }}"
            }
        },
        {
            "name": "JSON Key Level 1",
            "scope": ["source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "JSON Key Level 2",
            "scope": ["source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"],
            "settings": {
                "foreground": "{{ blue }}"
            }
        },
        {
            "name": "JSON Key Level 3",
            "scope": ["source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"],
            "settings": {
                "foreground": "{{ color13 }}"
            }
        },
        {
            "name": "JSON Key Level 4",
            "scope": ["source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "JSON Key Level 5+",
            "scope": ["source.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json meta.structure.dictionary.value.json meta.structure.dictionary.json support.type.property-name.json"],
            "settings": {
                "foreground": "{{ green }}"
            }
        },
        {
            "name": "Markdown Heading",
            "scope": ["markup.heading", "entity.name.section.markdown", "punctuation.definition.heading.markdown"],
            "settings": {
                "foreground": "{{ blue }}",
                "fontStyle": "bold"
            }
        },
        {
            "name": "Markdown Bold",
            "scope": ["markup.bold", "punctuation.definition.bold.markdown"],
            "settings": {
                "foreground": "{{ fg }}",
                "fontStyle": "bold"
            }
        },
        {
            "name": "Markdown Italic",
            "scope": ["markup.italic", "punctuation.definition.italic.markdown"],
            "settings": {
                "foreground": "{{ fg }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "Markdown Link",
            "scope": ["markup.underline.link", "string.other.link.title.markdown", "string.other.link.description.markdown"],
            "settings": {
                "foreground": "{{ blue }}"
            }
        },
        {
            "name": "Markdown Code",
            "scope": ["markup.inline.raw", "markup.fenced_code.block", "markup.raw.block"],
            "settings": {
                "foreground": "{{ green }}"
            }
        },
        {
            "name": "Markdown Quote",
            "scope": ["markup.quote", "punctuation.definition.quote.begin.markdown"],
            "settings": {
                "foreground": "{{ accent_dim }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "Markdown List",
            "scope": ["punctuation.definition.list.begin.markdown", "markup.list.numbered", "markup.list.unnumbered"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "Diff Inserted",
            "scope": ["markup.inserted", "punctuation.definition.inserted"],
            "settings": {
                "foreground": "{{ green }}"
            }
        },
        {
            "name": "Diff Deleted",
            "scope": ["markup.deleted", "punctuation.definition.deleted"],
            "settings": {
                "foreground": "{{ red }}"
            }
        },
        {
            "name": "Diff Changed",
            "scope": ["markup.changed", "punctuation.definition.changed"],
            "settings": {
                "foreground": "{{ orange }}"
            }
        },
        {
            "name": "This/Self",
            "scope": ["variable.language.this", "variable.language.self", "variable.language.special.self"],
            "settings": {
                "foreground": "{{ fg }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "Object Keys",
            "scope": ["meta.object-literal.key", "string.unquoted.label.js"],
            "settings": {
                "foreground": "{{ fg }}"
            }
        },
        {
            "name": "Rust Lifetime",
            "scope": ["entity.name.type.lifetime.rust", "punctuation.definition.lifetime.rust"],
            "settings": {
                "foreground": "{{ aqua }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "Rust Macro",
            "scope": ["entity.name.function.macro.rust", "support.function.macro.rust"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "Shell Variable",
            "scope": ["variable.other.normal.shell", "variable.other.positional.shell", "variable.other.bracket.shell"],
            "settings": {
                "foreground": "{{ fg }}"
            }
        },
        {
            "name": "Shell Command",
            "scope": ["entity.name.command.shell"],
            "settings": {
                "foreground": "{{ blue }}"
            }
        },
        {
            "name": "Shell Builtin",
            "scope": ["support.function.builtin.shell"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "YAML Key",
            "scope": ["entity.name.tag.yaml"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "TOML Key",
            "scope": ["keyword.key.toml", "support.type.property-name.toml"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "TOML Table",
            "scope": ["entity.other.attribute-name.table.toml", "support.type.property-name.table.toml"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "INI Section",
            "scope": ["entity.name.section.group-title.ini", "punctuation.definition.entity.ini"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "INI Key",
            "scope": ["keyword.other.definition.ini"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "Make Target",
            "scope": ["entity.name.function.target.makefile"],
            "settings": {
                "foreground": "{{ blue }}"
            }
        },
        {
            "name": "Make Variable",
            "scope": ["variable.other.makefile"],
            "settings": {
                "foreground": "{{ fg }}"
            }
        },
        {
            "name": "Go Package",
            "scope": ["entity.name.package.go"],
            "settings": {
                "foreground": "{{ blue }}"
            }
        },
        {
            "name": "Python Self",
            "scope": ["variable.parameter.function.language.special.self.python"],
            "settings": {
                "foreground": "{{ fg }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "Python Magic",
            "scope": ["support.function.magic.python", "support.variable.magic.python"],
            "settings": {
                "foreground": "{{ aqua }}",
                "fontStyle": "italic"
            }
        },
        {
            "name": "PHP Variable",
            "scope": ["variable.other.php", "punctuation.definition.variable.php"],
            "settings": {
                "foreground": "{{ fg }}"
            }
        },
        {
            "name": "C Preprocessor",
            "scope": ["meta.preprocessor.c", "meta.preprocessor.include.c", "keyword.control.directive.include.c"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "C# Attribute",
            "scope": ["meta.attribute.csharp", "entity.name.type.attribute.csharp"],
            "settings": {
                "foreground": "{{ aqua }}"
            }
        },
        {
            "name": "SQL Keyword",
            "scope": ["keyword.other.DML.sql", "keyword.other.DDL.sql"],
            "settings": {
                "foreground": "{{ color13 }}"
            }
        },
        {
            "name": "GraphQL Type",
            "scope": ["support.type.graphql", "entity.name.type.graphql"],
            "settings": {
                "foreground": "{{ yellow }}"
            }
        },
        {
            "name": "GraphQL Field",
            "scope": ["variable.graphql", "variable.other.graphql"],
            "settings": {
                "foreground": "{{ fg }}"
            }
        }
    ]
}
