# DouyinFollow 仿抖音关注功能

## 项目简介

**DouyinFollow** 是一个仿抖音关注列表的 iOS 项目。
- 项目背景：这是一个针对抖音关注页 的基于Objective-C的iOS仿写项目。


主要功能包括：
* 展示用户关注列表
* 支持用户备注修改
* 数据缓存与本地存储（NSUserDefaults）
* 支持设置特别关注（背景加灰 + 置顶）
* 支持下拉刷新
* 横向分页滑动 + 自动布局（Masonry）

## 技术栈
整体采用了MVC 的架构，使用Masonry 进行视图布局，AFNetWorking 进行网络请求并封装为单例类，JSONModel 进行数据转换，SDWebImage 进行头像加载的优化，Userdefault 实现一些信息的本地化存储。
  - 关注列表页面：基于UITableView 的自定义cell实现还原，并优化以提升性能，同时采用GCD优化性能，避免主线程阻塞。
  - 更多页面：使用代理传值向关注列表页面实时同步状态。

---

## 安装与运行

1. 克隆仓库

```bash
git clone https://github.com/你的仓库/DouyinFollow.git
```

2. 使用 Xcode 打开项目
3. 安装 Pods 依赖：

```bash
pod install
```

4. 运行项目

> 注意：如需网络数据，请配置模拟 API 或使用本地 JSON 文件。
> mork数据API：https://m1.apifoxmock.com/m1/7448820-7183141-default/api/v1/user/follow/list

---

## 项目结构

```
DouyinFollow/
├─ MainViewController.m       # 主控制器，管理分页和 segment
├─ FollowViewController.m     # 关注列表页面
├─ FollowUserModel.h/m        # 用户数据模型
├─ NetworkManager.h/m         # 网络请求管理
└─ Assets/                    # 头像图片或本地资源
```

---

## 未来优化方向

* 支持 **分组管理**
* **分片下载** 进行优化
* 使用 **CoreData 或 SQLite** 替代大规模关注列表存储
* 增加 **按关注时间或字母排序功能**
* 增加 **头像圆角、占位图**
* UI 优化，实现 **更接近原生抖音体验**

---

## 联系方式

开发者：TommyWu, from XiyouMobileGroup - iOS team
2025.11.24

---
