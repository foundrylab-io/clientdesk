import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { db } from '@/lib/db/drizzle';
import { 
  agencies, 
  clients, 
  projects, 
  proposals, 
  invoices,
  activityFeed 
} from '@/lib/db/schema';
import { getUser } from '@/lib/db/queries';
import { eq, desc, and, sum } from 'drizzle-orm';
import { 
  Users, 
  FolderOpen, 
  FileText, 
  DollarSign, 
  Clock, 
  Activity,
  Plus,
  Building2
} from 'lucide-react';
import { redirect } from 'next/navigation';

async function createClient(formData: FormData) {
  'use server';
  
  const user = await getUser();
  if (!user) return;

  // Get user's agency
  const userAgency = await db.query.agencies.findFirst({
    where: eq(agencies.userId, user.id)
  });

  if (!userAgency) return;

  const name = formData.get('name') as string;
  const email = formData.get('email') as string;
  const company = formData.get('company') as string;

  if (!name || !email) return;

  await db.insert(clients).values({
    userId: user.id,
    agencyId: userAgency.id,
    name,
    email,
    company: company || null
  });

  redirect('/dashboard');
}

async function createProject(formData: FormData) {
  'use server';
  
  const user = await getUser();
  if (!user) return;

  // Get user's agency
  const userAgency = await db.query.agencies.findFirst({
    where: eq(agencies.userId, user.id)
  });

  if (!userAgency) return;

  const name = formData.get('name') as string;
  const clientId = formData.get('clientId') as string;
  const description = formData.get('description') as string;

  if (!name || !clientId) return;

  await db.insert(projects).values({
    userId: user.id,
    agencyId: userAgency.id,
    clientId: parseInt(clientId),
    name,
    description: description || null
  });

  redirect('/dashboard');
}

export default async function DashboardPage() {
  const user = await getUser();
  
  if (!user) {
    redirect('/sign-in');
  }

  // Get user's agency
  const userAgency = await db.query.agencies.findFirst({
    where: eq(agencies.userId, user.id)
  });

  if (!userAgency) {
    redirect('/onboarding');
  }

  // Get dashboard data
  const [
    agencyClients,
    agencyProjects,
    agencyProposals,
    agencyInvoices,
    recentActivity,
    outstandingInvoicesTotal
  ] = await Promise.all([
    // Clients
    db.query.clients.findMany({
      where: eq(clients.agencyId, userAgency.id),
      orderBy: desc(clients.createdAt),
      limit: 5
    }),
    
    // Projects
    db.query.projects.findMany({
      where: eq(projects.agencyId, userAgency.id),
      with: {
        client: true
      },
      orderBy: desc(projects.createdAt),
      limit: 5
    }),
    
    // Proposals
    db.query.proposals.findMany({
      where: eq(proposals.agencyId, userAgency.id),
      with: {
        client: true,
        project: true
      },
      orderBy: desc(proposals.createdAt),
      limit: 5
    }),
    
    // Invoices
    db.query.invoices.findMany({
      where: eq(invoices.agencyId, userAgency.id),
      with: {
        client: true,
        project: true
      },
      orderBy: desc(invoices.createdAt),
      limit: 5
    }),
    
    // Recent Activity
    db.query.activityFeed.findMany({
      where: eq(activityFeed.agencyId, userAgency.id),
      orderBy: desc(activityFeed.createdAt),
      limit: 10
    }),
    
    // Outstanding invoices total
    db.select({
      total: sum(invoices.totalAmount)
    }).from(invoices)
    .where(
      and(
        eq(invoices.agencyId, userAgency.id),
        eq(invoices.status, 'unpaid')
      )
    )
  ]);

  const stats = {
    totalClients: agencyClients.length,
    activeProjects: agencyProjects.filter(p => p.status === 'active').length,
    pendingProposals: agencyProposals.filter(p => p.status === 'sent').length,
    outstandingAmount: outstandingInvoicesTotal[0]?.total || 0
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600 mt-1">Welcome back, {user.name}</p>
        </div>
        <div className="flex items-center gap-2">
          <Building2 className="h-5 w-5 text-gray-500" />
          <span className="text-sm text-gray-600">{userAgency.name}</span>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Clients</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.totalClients}</div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Projects</CardTitle>
            <FolderOpen className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.activeProjects}</div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pending Proposals</CardTitle>
            <FileText className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.pendingProposals}</div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Outstanding</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">${stats.outstandingAmount}</div>
          </CardContent>
        </Card>
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Clients */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="text-lg">Recent Clients</CardTitle>
            <Button size="sm" variant="outline">
              <Plus className="h-4 w-4 mr-1" />
              View All
            </Button>
          </CardHeader>
          <CardContent className="space-y-4">
            {agencyClients.length > 0 ? (
              agencyClients.map((client) => (
                <div key={client.id} className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                    <Users className="h-4 w-4 text-blue-600" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 truncate">
                      {client.name}
                    </p>
                    <p className="text-sm text-gray-500 truncate">
                      {client.company || client.email}
                    </p>
                  </div>
                  <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${
                    client.status === 'active' 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-gray-100 text-gray-800'
                  }`}>
                    {client.status}
                  </span>
                </div>
              ))
            ) : (
              <p className="text-sm text-gray-500">No clients yet</p>
            )}
          </CardContent>
        </Card>

        {/* Recent Projects */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="text-lg">Recent Projects</CardTitle>
            <Button size="sm" variant="outline">
              <Plus className="h-4 w-4 mr-1" />
              View All
            </Button>
          </CardHeader>
          <CardContent className="space-y-4">
            {agencyProjects.length > 0 ? (
              agencyProjects.map((project) => (
                <div key={project.id} className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                    <FolderOpen className="h-4 w-4 text-purple-600" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 truncate">
                      {project.name}
                    </p>
                    <p className="text-sm text-gray-500 truncate">
                      {project.client.name}
                    </p>
                  </div>
                  <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${
                    project.status === 'active' 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-gray-100 text-gray-800'
                  }`}>
                    {project.status}
                  </span>
                </div>
              ))
            ) : (
              <p className="text-sm text-gray-500">No projects yet</p>
            )}
          </CardContent>
        </Card>

        {/* Recent Activity */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg flex items-center">
              <Activity className="h-5 w-5 mr-2" />
              Recent Activity
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {recentActivity.length > 0 ? (
              recentActivity.map((activity) => (
                <div key={activity.id} className="flex items-start space-x-3">
                  <div className="w-2 h-2 bg-blue-500 rounded-full mt-2 flex-shrink-0"></div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-gray-900">
                      <span className="font-medium">{activity.actorName}</span>{' '}
                      {activity.description}
                    </p>
                    <p className="text-xs text-gray-500">
                      {new Date(activity.createdAt).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              ))
            ) : (
              <p className="text-sm text-gray-500">No recent activity</p>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Add Client Form */}
        <Card>
          <CardHeader>
            <CardTitle>Add New Client</CardTitle>
          </CardHeader>
          <CardContent>
            <form action={createClient} className="space-y-4">
              <div>
                <Input
                  name="name"
                  placeholder="Client Name"
                  required
                />
              </div>
              <div>
                <Input
                  name="email"
                  type="email"
                  placeholder="Email Address"
                  required
                />
              </div>
              <div>
                <Input
                  name="company"
                  placeholder="Company (Optional)"
                />
              </div>
              <Button type="submit" className="w-full">
                <Plus className="h-4 w-4 mr-2" />
                Add Client
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Add Project Form */}
        <Card>
          <CardHeader>
            <CardTitle>Add New Project</CardTitle>
          </CardHeader>
          <CardContent>
            <form action={createProject} className="space-y-4">
              <div>
                <Input
                  name="name"
                  placeholder="Project Name"
                  required
                />
              </div>
              <div>
                <select
                  name="clientId"
                  className="w-full px-3 py-2 border border-input rounded-md"
                  required
                >
                  <option value="">Select Client</option>
                  {agencyClients.map((client) => (
                    <option key={client.id} value={client.id}>
                      {client.name}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <Input
                  name="description"
                  placeholder="Project Description (Optional)"
                />
              </div>
              <Button type="submit" className="w-full" disabled={agencyClients.length === 0}>
                <Plus className="h-4 w-4 mr-2" />
                Add Project
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}