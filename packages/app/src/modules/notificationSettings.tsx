// import { createFrontendModule } from '@backstage/frontend-plugin-api';
// import { SubPageBlueprint } from '@backstage/frontend-plugin-api';

// export const notificationSettingsModule = createFrontendModule({
//   pluginId: 'user-settings',
//   extensions: [
//     SubPageBlueprint.make({
//       name: 'notifications',
//       params: {
//         path: 'notifications',
//         title: 'Notifications',
//         loader: () =>
//           import('./NotificationSettingsPage').then(m => (
//             <m.NotificationSettingsPage />
//           )),
//       },
//     }),
//   ],
// });