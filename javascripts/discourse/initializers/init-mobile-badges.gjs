import { apiInitializer } from "discourse/lib/api";
import HubPromoMobile from "../components/hub-promo-mobile";

export default apiInitializer("1.15.0", (api) => {
  api.renderAfterWrapperOutlet("home-logo-wrapper", HubPromoMobile);
});
