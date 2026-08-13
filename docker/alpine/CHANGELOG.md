# Changelog

## [18.4.0](https://github.com/snowdreamtech/postgresql/compare/alpine-v18.4.0...alpine-v18.4.0) (2026-08-13)


### 🚀 Features

* **alpine:** restore postgresql initialization script ([5d97e2f](https://github.com/snowdreamtech/postgresql/commit/5d97e2fcfccee51d35b8521c31bc9c200b283c21))
* un-align native versions to highest available per variant (alpine:18.4, debian:17.10, rocky:18.3) ([987f0de](https://github.com/snowdreamtech/postgresql/commit/987f0de4a2603c723895755c3f84fe993b5cd887))
* update dockerfiles for postgresql installation ([973143a](https://github.com/snowdreamtech/postgresql/commit/973143ac07db4107f103660452723dd134c83345))


### 🐛 Bug Fixes

* **alpine:** add empty line to trigger release pipeline test ([6f32fb1](https://github.com/snowdreamtech/postgresql/commit/6f32fb1c9fae9bcd4e86beb2e3013a0138784372))
* improve postgresql initialization script robustness across all variants ([51287b4](https://github.com/snowdreamtech/postgresql/commit/51287b4793cb4f541d3a3e617733f3fb9cab0b75))
* remove static version defaults from OCI image labels to use variable injection exclusively ([da5645a](https://github.com/snowdreamtech/postgresql/commit/da5645ad4d48467290235abbbd9f31ba70bf690f))
* resolve shellcheck and editorconfig errors reported by unirtm verify ([60a893e](https://github.com/snowdreamtech/postgresql/commit/60a893e7d21a9611d8f51d7fd2e1f42870136457))
* resolve shellcheck warnings in alpine postgresql-start.sh ([c1ee8bf](https://github.com/snowdreamtech/postgresql/commit/c1ee8bfbbb1830dde677151732e758f3e973fa93))
* set default values for numeric checks in entrypoint scripts ([6cf35df](https://github.com/snowdreamtech/postgresql/commit/6cf35dffd357f232050cc133e8bdeb3123c1ec19))
* set KEEPALIVE=1 to prevent container from exiting immediately ([20a366e](https://github.com/snowdreamtech/postgresql/commit/20a366e2bad64cefa8738ccad993414ccb362f5c))
* use ghcr.io for base images to avoid rate limits ([9f1d73a](https://github.com/snowdreamtech/postgresql/commit/9f1d73a75a61f2f368f5572c4bd28f4c92ef8fd5))


### 🛠 Refactoring

* **docker:** align Dockerfiles with base image structure ([232574f](https://github.com/snowdreamtech/postgresql/commit/232574fed8418f8c7f257d001e951361dfa467a0))
* remove redundant docker-entrypoint.sh files ([87c576b](https://github.com/snowdreamtech/postgresql/commit/87c576b27731ad11c5bc0ebc661e07c5a09ff1c1))
* reorganize distribution variants into docker directory ([67a8c91](https://github.com/snowdreamtech/postgresql/commit/67a8c911e21801bf12b3e83d02e22f3b3f59a2ba))


### 📖 Documentation

* add detailed comments to entrypoint initialization scripts ([f42cbaa](https://github.com/snowdreamtech/postgresql/commit/f42cbaab6edfbc5c38c2a636dfd8651fea900940))
* reset changelogs for postgresql migration ([1fd66f0](https://github.com/snowdreamtech/postgresql/commit/1fd66f065138d14d37f452a1f9e195518f3fcce4))


### ♻️ Miscellaneous Chores

* add 0-git-keep.sh to prevent empty entrypoint.d directories ([ce77247](https://github.com/snowdreamtech/postgresql/commit/ce77247762becc1edf85ec7b57747d3f3127044a))
* **deps:** bump base images to alpine 3.24.0, debian 13.5.0, rocky 10.2.0 ([1688969](https://github.com/snowdreamtech/postgresql/commit/168896956d2f4c7f91309c4c98ffef36ca7e8546))
* merge upstream/dev into dev ([9173112](https://github.com/snowdreamtech/postgresql/commit/91731120429d8b3ad9d35c98bc2cccce118afac4))
* release main ([5a92edb](https://github.com/snowdreamtech/postgresql/commit/5a92edb4ba76b04ee6de7369e9471f785849a7ae))
* release main ([afa286c](https://github.com/snowdreamtech/postgresql/commit/afa286c5b9c41908021b044f31fee3348f52c973))
* release main ([4011a21](https://github.com/snowdreamtech/postgresql/commit/4011a21a23395acc9545168c95ca0ec5c867e7d3))
* release main ([f66597a](https://github.com/snowdreamtech/postgresql/commit/f66597a5feae95e8853f4cc730c81e93e172f6ca))
* release main ([b3a5cc9](https://github.com/snowdreamtech/postgresql/commit/b3a5cc9ef0a64a7bc04ed7c2acf0cca5327c5c26))
* release main ([b3eb41d](https://github.com/snowdreamtech/postgresql/commit/b3eb41d309ef8280973d5196d83bdf0d5ce3f28e))
* release main ([a8ebfcf](https://github.com/snowdreamtech/postgresql/commit/a8ebfcf804892af37291111643b4935f4ad4012d))
* release main ([636f5b8](https://github.com/snowdreamtech/postgresql/commit/636f5b898d9266be5c76dc6b7151d6cab809e848))
* release main ([deb8454](https://github.com/snowdreamtech/postgresql/commit/deb8454df7518d56939ab3851245a4cd7b03d709))
* release main ([d87cb81](https://github.com/snowdreamtech/postgresql/commit/d87cb815685ad9b5b43d4b9a195c68dee2fd8065))
* release main ([78328d2](https://github.com/snowdreamtech/postgresql/commit/78328d20bd3697d48ea90aee8d0eaa6af4ccc09c))
* release main ([b720ad5](https://github.com/snowdreamtech/postgresql/commit/b720ad57dd1691d8ae07dcac7d46d0bd257af3a0))
* release main ([32dd84d](https://github.com/snowdreamtech/postgresql/commit/32dd84de4be973395d0867b5d527d528948a35df))
* release main ([725c69f](https://github.com/snowdreamtech/postgresql/commit/725c69fdcc222b5b83d0690629ce213a68c586ab))
* release main ([070b694](https://github.com/snowdreamtech/postgresql/commit/070b694a702763b60fc6b057a81418320418cafa))
* release main ([36d1211](https://github.com/snowdreamtech/postgresql/commit/36d1211036847a8c6aaa01a21a1c695a47b71d45))
* release main ([9ad4f94](https://github.com/snowdreamtech/postgresql/commit/9ad4f9490832efdc310f2ebbd8c77f3404daf07f))
* release main ([b0684a3](https://github.com/snowdreamtech/postgresql/commit/b0684a32a652e83506451e6056168cfec8b9142c))
* release main ([495e18a](https://github.com/snowdreamtech/postgresql/commit/495e18a4babcb06a12c2f5aec9ea571d97cb32e3))
* release main ([d4a3a34](https://github.com/snowdreamtech/postgresql/commit/d4a3a34b00a6b9f381cd5d556749c257516b2f08))
* release main ([28d9426](https://github.com/snowdreamtech/postgresql/commit/28d94263f4374017274707faef7183917b689be9))
* **release:** deduplicate CHANGELOG headers ([c2bba24](https://github.com/snowdreamtech/postgresql/commit/c2bba247dca89a31accc6e70c5e48b16170b1ce5))
* **release:** deduplicate CHANGELOG headers ([4f07b71](https://github.com/snowdreamtech/postgresql/commit/4f07b71194f58ba214f1fb60ce0dc56d71c499e2))
* **release:** deduplicate CHANGELOG headers ([82be3d5](https://github.com/snowdreamtech/postgresql/commit/82be3d5576b65b7f69b1a9afb8604f2c8f0e47f7))
* **release:** deduplicate CHANGELOG headers ([8a5befb](https://github.com/snowdreamtech/postgresql/commit/8a5befbac78d600e69213707b28dbbaecb3f0998))
* **release:** deduplicate CHANGELOG headers ([f80b984](https://github.com/snowdreamtech/postgresql/commit/f80b98496bfe5f810e8da8a71cc279b404ad317d))
* **release:** deduplicate CHANGELOG headers ([d47fb44](https://github.com/snowdreamtech/postgresql/commit/d47fb44cb105b368722d7d0e210a27b525f82d87))
* **release:** deduplicate CHANGELOG headers ([e795177](https://github.com/snowdreamtech/postgresql/commit/e79517795d98b9f8292ef956586a6dc03932d03c))
* **release:** deduplicate CHANGELOG headers ([27919e4](https://github.com/snowdreamtech/postgresql/commit/27919e4baf4aab5b2a2bf32a7d437b05a717c11b))
* **release:** deduplicate CHANGELOG headers ([438190d](https://github.com/snowdreamtech/postgresql/commit/438190d297c151c75eca4912fdc22c285d5ec1ea))
* **release:** deduplicate CHANGELOG headers ([256f043](https://github.com/snowdreamtech/postgresql/commit/256f04311b2344f2648ca5bcf407146f8c690258))
* **release:** deduplicate CHANGELOG headers ([d263aae](https://github.com/snowdreamtech/postgresql/commit/d263aae7b223103a01dd0e114430381c5d863dd7))
* **release:** deduplicate CHANGELOG headers ([133954e](https://github.com/snowdreamtech/postgresql/commit/133954e95cfae85cbba2fb9c1ac5acbc677ca39d))
* **release:** deduplicate CHANGELOG headers ([1d82410](https://github.com/snowdreamtech/postgresql/commit/1d82410d6038be22d7741f1519826f30023b0f3e))
* **release:** deduplicate CHANGELOG headers ([5e1a539](https://github.com/snowdreamtech/postgresql/commit/5e1a5390319933b48d20ad993714587d826c0aa7))
* **release:** implement automatic changelog deduplication step ([282c220](https://github.com/snowdreamtech/postgresql/commit/282c22081e1ad7a1a010a7f297d20bc7c9b416a7))
* remove redundant 10-base-init.sh scripts ([8216c4a](https://github.com/snowdreamtech/postgresql/commit/8216c4ac1b16d145e92894718a697ad7b83729ce))
* update alpine base image to 3.24.1 ([3021ed3](https://github.com/snowdreamtech/postgresql/commit/3021ed3b4ffa5f8916f5fa46aa4325e8ebf84ba6))

## [18.4.0](https://github.com/snowdreamtech/postgresql/compare/alpine-v18.4.0...alpine-v18.4.0) (2026-06-23)


### 🐛 Bug Fixes

* set default values for numeric checks in entrypoint scripts ([6cf35df](https://github.com/snowdreamtech/postgresql/commit/6cf35dffd357f232050cc133e8bdeb3123c1ec19))
