/** 部署在子路径（项目仓库 /repo）时，给站内链接补上 base 前缀 */
const base = import.meta.env.BASE_URL.replace(/\/$/, '');

export function b(path: string): string {
  return base + (path.startsWith('/') ? path : `/${path}`);
}
