import { defineStore } from 'pinia'

export const useDev = defineStore('dev', () => {
  const showDevLogs = ref<boolean>(true)

  function toggleDevLogs() {
    showDevLogs.value = !showDevLogs.value
  }

  return {
    // Properties
    showDevLogs: readonly(showDevLogs),

    // Functions
    toggleDevLogs,
  }
})
