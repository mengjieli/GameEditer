package egret.ui.skins.themes
{
	import egret.components.Theme;
	import egret.ui.skins.ButtonSkin;
	import egret.ui.skins.CheckBoxSkin;
	import egret.ui.skins.ColorPickerSkin;
	import egret.ui.skins.ComboBoxSkin;
	import egret.ui.skins.DataGridSkin;
	import egret.ui.skins.DefaultItemRendererSkin;
	import egret.ui.skins.DropDownListSkin;
	import egret.ui.skins.DropDownTextInputSkin;
	import egret.ui.skins.IconButtonSkin;
	import egret.ui.skins.IconItemRendererSkin;
	import egret.ui.skins.IconListSkin;
	import egret.ui.skins.IconTabBarButtonSkin;
	import egret.ui.skins.IconToggleButtonSkin;
	import egret.ui.skins.ListSkin;
	import egret.ui.skins.MenuBarItemRendererSkin;
	import egret.ui.skins.MenuIconButtonSkin;
	import egret.ui.skins.MenuItemRendererSkin;
	import egret.ui.skins.MenuSkin;
	import egret.ui.skins.NumberRegulatorSkin;
	import egret.ui.skins.RadioButtonSkin;
	import egret.ui.skins.TabBarSkin;
	import egret.ui.skins.TabPanelSkin;
	import egret.ui.skins.TextAreaSkin;
	import egret.ui.skins.TextInputSkin;
	import egret.ui.skins.TreeItemRendererSkin;
	import egret.ui.skins.scrollBarSkin.HScrollBarSkin;
	import egret.ui.skins.scrollBarSkin.ScrollerSkin;
	import egret.ui.skins.scrollBarSkin.VScrollBarSkin;
	
	/**
	 * Egret主题皮肤默认配置
	 * @author 雷羽佳
	 */
	public class EgretTheme extends Theme
	{
		public function EgretTheme()
		{
			super();
		}
		
		override protected function mapSkin():void
		{
			skinMap["egret.components::Button"] = ButtonSkin;
			skinMap["egret.components::RadioButton"] = RadioButtonSkin;
			skinMap["egret.components::Scroller"] = ScrollerSkin;
			skinMap["egret.components::DataGrid"] = DataGridSkin;
			skinMap["egret.ui.components::TextInput"] = TextInputSkin;
			skinMap["egret.ui.components::TabPanel"] = TabPanelSkin;
			skinMap["egret.components::TextArea"] = TextAreaSkin;
			skinMap["egret.ui.components::IconTabBarButton"] = IconToggleButtonSkin;
			skinMap["egret.ui.components::IconList"] = IconListSkin;
			skinMap["egret.ui.components::IconItemRenderer"] = IconItemRendererSkin;
			skinMap["egret.ui.components::IconButton"] = IconButtonSkin;
			skinMap["egret.ui.components::DropDownTextInput"] = DropDownTextInputSkin;
			skinMap["egret.components::DropDownList"] = DropDownListSkin;
			skinMap["egret.components.supportClasses::ItemRenderer"] = DefaultItemRendererSkin;
			skinMap["egret.ui.components::ComboBox"] = ComboBoxSkin;
			skinMap["egret.components::CheckBox"] = CheckBoxSkin;
			skinMap["egret.ui.components::ColorPicker"] = ColorPickerSkin;
			skinMap["egret.components::TabBarButton"] = IconTabBarButtonSkin;
			skinMap["egret.components.menuClasses::MenuBarItemRenderer"] = MenuBarItemRendererSkin;
			skinMap["egret.components::HScrollBar"] = HScrollBarSkin;
			skinMap["egret.components::VScrollBar"] = VScrollBarSkin;
			skinMap["egret.components.supportClasses::TreeItemRenderer"] = TreeItemRendererSkin;
			skinMap["egret.components::TabBar"] = TabBarSkin;
			skinMap["egret.components::List"] = ListSkin;
			skinMap["egret.components::Tree"] = ListSkin;
			skinMap["egret.ui.components::Tree"] = ListSkin;
			skinMap["egret.ui.components::NumberRegulator"] = NumberRegulatorSkin;
			skinMap["egret.ui.components::DropDownList"] = DropDownListSkin;
			skinMap["egret.ui.components::MenuIconButton"] = MenuIconButtonSkin;
			skinMap["egret.components.menuClasses::MenuItemRenderer"] = MenuItemRendererSkin;
			skinMap["egret.components::Menu"] = MenuSkin;
		}
	}
}