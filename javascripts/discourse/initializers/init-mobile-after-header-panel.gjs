import { apiInitializer } from "discourse/lib/api";
import FaqButton from "../components/faq-button";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet("after-header-panel", FaqButton);
});
