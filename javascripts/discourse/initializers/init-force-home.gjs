import { apiInitializer } from "discourse/lib/api";
import { defaultHomepage } from "discourse/lib/utilities";

export default apiInitializer("1.15.0", (api) => {
  // anons can't do anything outside of home
  // so force them back home
  api.onPageChange(() => {
    const router = api.container.lookup("service:router");
    const currentUser = api.container.lookup("service:current-user");
    const currentRouteName = router?.currentRouteName;

    const excludeRoutes = [
      "login",
      "email-login",
      `discovery.${defaultHomepage()}`,
    ];

    if (!currentUser && !excludeRoutes.includes(currentRouteName)) {
      router.transitionTo("/");
    }
  });
});
