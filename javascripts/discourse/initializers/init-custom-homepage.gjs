import { apiInitializer } from "discourse/lib/api";
import CustomHomepage from "../components/custom-homepage";
import HeaderNav from "../components/header-nav";

export default apiInitializer((api) => {
  api.renderInOutlet("before-header-panel", HeaderNav);
  api.renderInOutlet("custom-homepage", CustomHomepage);
});
