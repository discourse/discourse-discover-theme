import { apiInitializer } from "discourse/lib/api";
import { defaultHomepage } from "discourse/lib/utilities";

export default apiInitializer("1.15.0", (api) => {
  // anons can't do anything outside of home
  // so force them back home
  api.onPageChange(() => {
    const router = api.container.lookup("service:router");
    const currentUser = api.container.lookup("service:currentUser");
    const currentRouteName = router?.currentRouteName;
    if (!currentUser && currentRouteName !== `discovery.${defaultHomepage()}`) {
      router.transitionTo("/");
    }
  });
});
