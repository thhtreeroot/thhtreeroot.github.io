// @ts-check
import { defineConfig } from 'astro/config';

// 个人主页仓库（<用户名>.github.io）：保持 base '/'。
// 项目仓库（<用户名>.github.io/<repo>）：把 site 改成主页地址、base 改成 '/<repo>'。
export default defineConfig({
  site: 'https://thhtreeroot.github.io',
  base: '/',
  trailingSlash: 'never',
});
