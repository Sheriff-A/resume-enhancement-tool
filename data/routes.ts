interface Route {
  label: string
  path: string
  icon?: string
}

export const LANDING_ROUTES: Route[] = [
  {
    label: 'Home',
    path: '/#hero',
  },
  {
    label: 'About',
    path: '/#about',
  },
  {
    label: 'Philosophy',
    path: '/#philosophy',
  },
  {
    label: 'Get Started',
    path: '/#get-started',
  },
]
export const DASHBOARD_ROUTES: Route[] = [
  {
    label: 'Dashboard',
    path: '/dashboard',
  },
  {
    label: 'Resumes',
    path: '/resume',
  },
  {
    label: 'Reviews',
    path: '/score',
  },
  {
    label: 'Settings',
    path: '/settings',
  },
]
