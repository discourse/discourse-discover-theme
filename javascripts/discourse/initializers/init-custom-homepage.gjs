import { apiInitializer } from "discourse/lib/api";
import CustomHomepage from "../components/custom-homepage";

export default apiInitializer((api) => {
  api.renderInOutlet("custom-homepage", CustomHomepage);
});
