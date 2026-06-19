pragma Singleton

import QtQuick

QtObject {
    readonly property int windowWidth: 900
    readonly property int windowHeight: 600

    readonly property int spacingNone: 0
    readonly property int spacingXSmall: 5
    readonly property int spacingSmall: 6
    readonly property int spacingMedium: 8
    readonly property int spacingLarge: 10

    readonly property int pageMargin: 24
    readonly property int sidebarWidth: 180
    readonly property int sidebarMargin: 12
    readonly property int modalPadding: 15

    readonly property int text: 16
    readonly property int textSmall: 14
    readonly property int textStatus: 13
    readonly property int textSubtitle: 11
    readonly property int textDelegate: 15
    readonly property int textTitle: 20
    readonly property int textAppTitle: 22

    readonly property int controlBorderWidth: 1
    readonly property int controlFocusBorderWidth: 2
    readonly property int controlRadiusSmall: 4
    readonly property int controlRadiusMedium: 6
    readonly property int controlRadiusLarge: 8
    readonly property int controlRadiusXLarge: 11

    readonly property int buttonHeight: 52
    readonly property int buttonHorizontalPadding: 24
    readonly property int buttonHeightSmall: 43
    readonly property int buttonHeightMedium: 44

    readonly property int textFieldHeight: 36
    readonly property int textFieldFadeInset: 1
    readonly property int textFieldFadeWidth: 24
    readonly property int textFieldDefaultLabelWidth: 200
    readonly property int textFieldDefaultFieldWidth: 300
    readonly property int textFieldModalLabelWidth: 180
    readonly property int textFieldModalFieldWidth: 200
    readonly property int textFieldValidationDelay: 1000

    readonly property int sidebarTitleBottomMargin: 16
    readonly property int sidebarUnderlineHeight: 3
    readonly property int sidebarUnderlineHeightInactive: 2

    readonly property int iconSmall: 15
    readonly property int iconMedium: 18
    readonly property int iconLarge: 30

    readonly property int modalSpacerHeight: 50
    readonly property int comboBoxHeight: 50
    readonly property int comboBoxLeftPadding: 12
    readonly property int comboBoxRightPadding: 40
    readonly property int comboBoxIndicatorSize: 10
    readonly property int comboBoxIndicatorRightMargin: 16
    readonly property int comboBoxDelegateHeight: 44
    readonly property int comboBoxIconColumnWidth: 30
}
