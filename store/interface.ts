export const useInterfaceStore = defineStore('interface', () => {
  const loaderMsg = ref<string>();

  function showLoader(message?: string) {
    loaderMsg.value = message ?? 'Loading...';
  }

  function hideLoader() {
    loaderMsg.value = undefined;
  }

  return {
    // Properties
    loaderMsg: loaderMsg,

    // Functions
    showLoader,
    hideLoader,
  };
});
