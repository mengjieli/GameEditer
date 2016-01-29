package egret.skins.themes
{
	import egret.components.Theme;
	import egret.skins.vector.AlertSkin;
	import egret.skins.vector.ApplicationSkin;
	import egret.skins.vector.ButtonSkin;
	import egret.skins.vector.CheckBoxSkin;
	import egret.skins.vector.ComboBoxSkin;
	import egret.skins.vector.DataGridSkin;
	import egret.skins.vector.DropDownListSkin;
	import egret.skins.vector.HScrollBarSkin;
	import egret.skins.vector.HSliderSkin;
	import egret.skins.vector.ItemRendererSkin;
	import egret.skins.vector.ListSkin;
	import egret.skins.vector.MenuBarItemRendererSkin;
	import egret.skins.vector.MenuBarSkin;
	import egret.skins.vector.MenuItemRendererSkin;
	import egret.skins.vector.MenuSkin;
	import egret.skins.vector.PageNavigatorSkin;
	import egret.skins.vector.PanelSkin;
	import egret.skins.vector.ProgressBarSkin;
	import egret.skins.vector.RadioButtonSkin;
	import egret.skins.vector.ScrollerSkin;
	import egret.skins.vector.SkinnableContainerSkin;
	import egret.skins.vector.SkinnableDataContainerSkin;
	import egret.skins.vector.TabBarButtonSkin;
	import egret.skins.vector.TabBarSkin;
	import egret.skins.vector.TabNavigatorSkin;
	import egret.skins.vector.TextAreaSkin;
	import egret.skins.vector.TextInputSkin;
	import egret.skins.vector.TitleWindowSkin;
	import egret.skins.vector.ToggleButtonSkin;
	import egret.skins.vector.TreeItemRendererSkin;
	import egret.skins.vector.VScrollBarSkin;
	import egret.skins.vector.VSliderSkin;
	import egret.skins.vector.WindowSkin;
	
	
	/**
	 * Vector主题皮肤默认配置
	 * @author dom
	 */
	public class VectorTheme extends Theme
	{
		public function VectorTheme()
		{
			super();
		}
		
		override protected function mapSkin():void
		{
			skinMap["egret.components::Alert"] = AlertSkin;
			skinMap["egret.components::Button"] = ButtonSkin;
			skinMap["egret.components::CheckBox"] = CheckBoxSkin;
			skinMap["egret.components::ComboBox"] = ComboBoxSkin;
			skinMap["egret.components::DropDownList"] = DropDownListSkin;
			skinMap["egret.components::DataGrid"] = DataGridSkin;
			skinMap["egret.components::HScrollBar"] = HScrollBarSkin;
			skinMap["egret.components::HSlider"] = HSliderSkin;
			skinMap["egret.components::List"] = ListSkin;
			skinMap["egret.components::PageNavigator"] = PageNavigatorSkin;
			skinMap["egret.components::Panel"] = PanelSkin;
			skinMap["egret.components::ProgressBar"] = ProgressBarSkin;
			skinMap["egret.components::RadioButton"] = RadioButtonSkin;
			skinMap["egret.components::Scroller"] = ScrollerSkin;
			skinMap["egret.components::SkinnableContainer"] = SkinnableContainerSkin;
			skinMap["egret.components::SkinnableDataContainer"] = SkinnableDataContainerSkin;
			skinMap["egret.components::TabBar"] = TabBarSkin;
			skinMap["egret.components::TabBarButton"] = TabBarButtonSkin;
			skinMap["egret.components::TabNavigator"] = TabNavigatorSkin;
			skinMap["egret.components::TextArea"] = TextAreaSkin;
			skinMap["egret.components::TextInput"] = TextInputSkin;
			skinMap["egret.components::TitleWindow"] = TitleWindowSkin;
			skinMap["egret.components::ToggleButton"] = ToggleButtonSkin;
			skinMap["egret.components::Tree"] = ListSkin;
			skinMap["egret.components.supportClasses::TreeItemRenderer"] = TreeItemRendererSkin;
			skinMap["egret.components::Menu"] = MenuSkin;
			skinMap["egret.components.menuClasses::MenuItemRenderer"] = MenuItemRendererSkin;
			skinMap["egret.components::VScrollBar"] = VScrollBarSkin;
			skinMap["egret.components::VSlider"] = VSliderSkin;
			skinMap["egret.components.supportClasses::ItemRenderer"] = ItemRendererSkin;
			skinMap["egret.components::Window"] = WindowSkin;
			skinMap["egret.components::Application"] = ApplicationSkin;
			skinMap["egret.components::MenuBar"] = MenuBarSkin;
			skinMap["egret.components.menuClasses::MenuBarItemRenderer"] = MenuBarItemRendererSkin;
		}
		
	}
}