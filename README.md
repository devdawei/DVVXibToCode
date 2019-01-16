DVVXibToCode
===========
根据 xib 文件自动生成属性、添加视图、约束(使用[PureLayout](https://github.com/PureLayout/PureLayout))和Getter方法代码。

使用方式
-------
1. 下载并运行项目，运行好后会打开主窗体；
2. 将 xib 文件路径拖到 Xib File Path 中；
3. 选择 Xib File Type；
4. 点击 Cover 即可转换；


xib文件注意事项
-------------
1. 新建好xib文件后，将xib文件的`Use Safe Area Layout Guides`选项去掉。如下图红框中所示：
![Uncheck Use Safe Area Layout Guides.png](https://raw.githubusercontent.com/devdawei/DVVXibToCode/master/DocLinkImg/Uncheck_Use_Safe_Area_Layout_Guides.png)

2. 拖完控件后，一定要更改控件名，因为生成的属性名就是控件名。如下图红框中所示：
![Change_control_name.png](https://raw.githubusercontent.com/devdawei/DVVXibToCode/master/DocLinkImg/Change_control_name.png)

3. 添加约束时，需要先把`Constrain to margins`选项去掉。如下图红框中所示：
![Uncheck Constrain to margins.png](https://raw.githubusercontent.com/devdawei/DVVXibToCode/master/DocLinkImg/Uncheck_Constrain_to_margins.png)

目前所支持的 xib 文件类型
---------------------
- UIView
- UIViewController
- UITableViewCell
- UICollectionViewCell

目前所支持的控件及属性
------------------
__颜色设置：目前仅支持通过 [RGB Sliders](https://raw.githubusercontent.com/devdawei/DVVXibToCode/master/DocLinkImg/RGB_Sliders.png) 设置。__  
__字体设置：System 类型目前仅支持设置 Style(Regular、Bold) 和 Size；Custom 类型可设置 Family，Style，Size。__

* __UIView__
    - Background
* __UILabel__
    - Text(Plain)
    - Color
    - Font
    - Alignment
* __UITextField__
    - Color
    - Font
    - Alignment
    - Placeholder
* __UITextView__
    - Text(Plain)
    - Color
    - Font
    - Alignment
* __UIButton__
    - Type(Custom、System)
    - State Config(Default)
    - Title(Plain)
    - Font
    - Text Color
* __UIImageView__
    - Image
* __UISwitch__
* __UITableView__
    - Style(Plain、Grouped)
* __UIScrollView__

自动生成效果
----------
![DVVXibToCode.png](https://raw.githubusercontent.com/devdawei/DVVXibToCode/master/DocLinkImg/DVVXibToCode.png)
