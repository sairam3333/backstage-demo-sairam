import { createApp } from '@backstage/frontend-defaults';
import catalogPlugin from '@backstage/plugin-catalog/alpha';
import { navModule } from './modules/nav';

import { oktaAuthApiRef  } from '@backstage/core-plugin-api';
import { SignInPageBlueprint } from '@backstage/plugin-app-react';
import { SignInPage } from '@backstage/core-components';
import { createFrontendModule } from '@backstage/frontend-plugin-api';
import techRadarPlugin from '@backstage-community/plugin-tech-radar/alpha';
import { techDocsReportIssueAddonModule } from '@backstage/plugin-techdocs-module-addons-contrib/alpha';

const signInPage = SignInPageBlueprint.make({
  params: {
    loader: async () => props =>
      (
        <SignInPage
          {...props}
          provider={{
            id: 'okta-auth-provider',
            title: 'Okta',
            message: 'Sign in using Okta',
            apiRef: oktaAuthApiRef,
          }}
        />
      ),
  },
});
export default createApp({
  features: [
    catalogPlugin,
    navModule,
    techRadarPlugin,
    techDocsReportIssueAddonModule,
    createFrontendModule({
      pluginId: 'app',
      extensions: [signInPage],
    }),
  ],
});