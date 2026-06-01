/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_POLYGON_RPC_URL?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}

// Ethereum provider types
interface EthereumProvider {
  isMetaMask?: boolean
  request(args: { method: string; params?: any[] }): Promise<any>
  on(event: string, handler: (...args: any[]) => void): void
  removeListener(event: string, handler: (...args: any[]) => void): void
}

interface Window {
  ethereum?: EthereumProvider
}
