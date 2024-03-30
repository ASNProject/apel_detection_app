// Copyright 2024 ariefsetyonugroho
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:apel_detection_app/cores/routers/app_routes.dart';
import 'package:apel_detection_app/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter returnRouter(bool isAuth) {
    GoRouter router = GoRouter(
        routes: [
          GoRoute(
              name: AppRoutes.dashboardScreen,
              path: AppRoutes.dashboardScreen,
              builder: (context, state) {
                return const DashboardScreen();
              })
        ],
        errorBuilder: (context, state) {
          return const Scaffold(
            body: Center(
              child: Text('Halaman tidak tesedia'),
            ),
          );
        });
    return router;
  }
}
