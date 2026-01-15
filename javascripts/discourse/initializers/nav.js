import { withPluginApi } from "discourse/lib/plugin-api";
import HeaderActions from "../components/header-actions";

export default {
  name: "add-custom-nav",

  initialize() {
    withPluginApi((api) => {
      api.headerButtons.add("header-actions", HeaderActions);
    });
  },
};
