{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // این خط به فلاتر می‌فهماند که موتور وب را از پوشه محلی بخواند
    canvasKitBaseUrl: "canvaskit/"
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  }
});