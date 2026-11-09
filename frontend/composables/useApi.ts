import { createApi, type Fetcher } from '~/utils/api'

export function useApi() {
  const config = useRuntimeConfig()
  return createApi(config.public.apiBase as string, $fetch as Fetcher)
}
