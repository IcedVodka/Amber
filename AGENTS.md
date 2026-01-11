1. 优先使用原生高级组件，比如ListTile，ExpansionTile，SwitchListTile，CheckboxListTile，Card，CircleAvatar，Chip 系列 (InputChip, FilterChip, ActionChip)，SliverAppBar，GridTile等。   
2. 组件开发的时候嵌套最多为3，不要超过3。遇到复杂的组件，把子组件提取成小变量或小函数或者提取子组件成一个类。
3. xxx_page.dart 写组合逻辑，组件实现放到对应的weight文件夹下。
4. 轻量化开发，不要做额外的防御性编程
5. 测试代码放到tset文件夹下
6. json写入不要一行写入，漂亮的格式化加上一定的回车，方便用户观看