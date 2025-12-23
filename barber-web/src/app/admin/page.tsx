'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { FinancialTransaction } from '@/types'
import {
    Store, Users, Calendar, DollarSign,
    TrendingUp, Scissors, ChevronRight,
    Plus, Settings, Shield
} from 'lucide-react'

interface DashboardStats {
    totalBarbershops: number
    totalBarbers: number
    totalClients: number
    totalBookings: number
    todayBookings: number
    monthRevenue: number
    activePlans: number
}

interface Barbershop {
    id: string
    name: string
    slug: string
    city: string | null
    is_active: boolean
    created_at: string
    _count?: {
        barbers: number
        bookings: number
    }
}

export default function AdminDashboard() {
    const router = useRouter()
    const [stats, setStats] = useState<DashboardStats>({
        totalBarbershops: 0,
        totalBarbers: 0,
        totalClients: 0,
        totalBookings: 0,
        todayBookings: 0,
        monthRevenue: 0,
        activePlans: 0
    })
    const [recentBarbershops, setRecentBarbershops] = useState<Barbershop[]>([])
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        checkAdmin()
        fetchDashboardData()
    }, [])

    const checkAdmin = async () => {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) {
            router.push('/auth')
            return
        }

        const { data: profile } = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single()

        if (!profile || profile.role !== 'admin') {
            router.push('/auth')
        }
    }

    const fetchDashboardData = async () => {
        setLoading(true)

        // Fetch barbershops count
        const { count: barbershopsCount } = await supabase
            .from('barbershops')
            .select('*', { count: 'exact', head: true })

        // Fetch barbers count
        const { count: barbersCount } = await supabase
            .from('barbers')
            .select('*', { count: 'exact', head: true })

        // Fetch clients count
        const { count: clientsCount } = await supabase
            .from('clients')
            .select('*', { count: 'exact', head: true })

        // Fetch bookings count
        const { count: bookingsCount } = await supabase
            .from('barbershop_bookings')
            .select('*', { count: 'exact', head: true })

        // Fetch today's bookings
        const today = new Date()
        today.setHours(0, 0, 0, 0)
        const tomorrow = new Date(today)
        tomorrow.setDate(tomorrow.getDate() + 1)

        const { count: todayCount } = await supabase
            .from('barbershop_bookings')
            .select('*', { count: 'exact', head: true })
            .gte('start_time', today.toISOString())
            .lt('start_time', tomorrow.toISOString())

        // Fetch active subscriptions
        const { count: subscriptionsCount } = await supabase
            .from('client_subscriptions')
            .select('*', { count: 'exact', head: true })
            .eq('is_active', true)

        // Fetch recent barbershops
        const { data: barbershops } = await supabase
            .from('barbershops')
            .select('*')
            .order('created_at', { ascending: false })
            .limit(5)

        // Calculate month revenue
        const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1)
        const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0, 23, 59, 59, 999)

        const { data: financialTransactions, error: financialError } = await supabase
            .from('financial_transactions')
            .select('amount')
            .gte('created_at', startOfMonth.toISOString())
            .lt('created_at', endOfMonth.toISOString())

        if (financialError) {
            console.error('Error fetching financial transactions:', financialError)
        }

        const calculatedMonthRevenue = financialTransactions?.reduce((sum, transaction) => sum + transaction.amount, 0) || 0

        setStats({
            totalBarbershops: barbershopsCount || 0,
            totalBarbers: barbersCount || 0,
            totalClients: clientsCount || 0,
            totalBookings: bookingsCount || 0,
            todayBookings: todayCount || 0,
            monthRevenue: calculatedMonthRevenue,
            activePlans: subscriptionsCount || 0
        })

        setRecentBarbershops(barbershops || [])
        setLoading(false)
    }

    if (loading) {
        return (
            <div className="min-h-screen bg-dark-bg flex items-center justify-center">
                <div className="text-gold text-xl">Carregando Painel Admin...</div>
            </div>
        )
    }

    return (
        <div className="min-h-screen bg-dark-bg">
            {/* Header */}
            <header className="bg-dark-card border-b border-white/10 px-8 py-4">
                <div className="max-w-7xl mx-auto flex justify-between items-center">
                    <div className="flex items-center gap-3">
                        <Shield className="text-gold" size={28} />
                        <h1 className="text-2xl font-bold text-white">FOC Barber Admin</h1>
                    </div>
                    <nav className="flex gap-6">
                        <Link href="/admin" className="text-gold font-medium">Dashboard</Link>
                        <Link href="/admin/barbershops" className="text-gray-400 hover:text-white transition">Barbearias</Link>
                        <Link href="/admin/users" className="text-gray-400 hover:text-white transition">Usuários</Link>
                        <Link href="/admin/financial" className="text-gray-400 hover:text-white transition">Financeiro</Link>
                        <Link href="/admin/settings" className="text-gray-400 hover:text-white transition">
                            <Settings size={20} />
                        </Link>
                    </nav>
                </div>
            </header>

            <main className="max-w-7xl mx-auto p-8">
                {/* Stats Grid */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-10">
                    <StatCard
                        icon={<Store className="text-gold" />}
                        label="Barbearias"
                        value={stats.totalBarbershops}
                        trend="+2 este mês"
                    />
                    <StatCard
                        icon={<Scissors className="text-blue-400" />}
                        label="Barbeiros"
                        value={stats.totalBarbers}
                    />
                    <StatCard
                        icon={<Users className="text-green-400" />}
                        label="Clientes"
                        value={stats.totalClients}
                    />
                    <StatCard
                        icon={<Calendar className="text-purple-400" />}
                        label="Agendamentos Hoje"
                        value={stats.todayBookings}
                    />
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Recent Barbershops */}
                    <div className="lg:col-span-2">
                        <div className="flex justify-between items-center mb-6">
                            <h2 className="text-xl font-bold text-white">Barbearias Recentes</h2>
                            <Link
                                href="/admin/barbershops/new"
                                className="flex items-center gap-2 bg-gold text-black px-4 py-2 rounded-lg font-medium hover:bg-gold/90 transition"
                            >
                                <Plus size={18} />
                                Nova Barbearia
                            </Link>
                        </div>

                        <div className="space-y-4">
                            {recentBarbershops.length === 0 ? (
                                <GlassCard className="p-8 text-center">
                                    <Store className="mx-auto text-gray-500 mb-4" size={48} />
                                    <p className="text-gray-400">Nenhuma barbearia cadastrada</p>
                                    <Link
                                        href="/admin/barbershops/new"
                                        className="inline-block mt-4 text-gold hover:underline"
                                    >
                                        Cadastrar primeira barbearia
                                    </Link>
                                </GlassCard>
                            ) : (
                                recentBarbershops.map(shop => (
                                    <Link key={shop.id} href={`/admin/barbershops/${shop.id}`}>
                                        <GlassCard className="p-4 hover:bg-white/5 transition cursor-pointer group">
                                            <div className="flex justify-between items-center">
                                                <div className="flex items-center gap-4">
                                                    <div className="w-12 h-12 bg-gold/20 rounded-full flex items-center justify-center">
                                                        <Store className="text-gold" size={24} />
                                                    </div>
                                                    <div>
                                                        <h3 className="font-bold text-white">{shop.name}</h3>
                                                        <p className="text-sm text-gray-400">
                                                            {shop.city || 'Sem localização'} • {shop.slug}
                                                        </p>
                                                    </div>
                                                </div>
                                                <div className="flex items-center gap-4">
                                                    <span className={`px-3 py-1 rounded-full text-xs ${
                                                        shop.is_active
                                                            ? 'bg-green-500/20 text-green-400'
                                                            : 'bg-red-500/20 text-red-400'
                                                    }`}>
                                                        {shop.is_active ? 'Ativo' : 'Inativo'}
                                                    </span>
                                                    <ChevronRight className="text-gray-500 group-hover:text-gold transition" />
                                                </div>
                                            </div>
                                        </GlassCard>
                                    </Link>
                                ))
                            )}
                        </div>

                        {recentBarbershops.length > 0 && (
                            <Link
                                href="/admin/barbershops"
                                className="block text-center mt-4 text-gold hover:underline"
                            >
                                Ver todas as barbearias
                            </Link>
                        )}
                    </div>

                    {/* Quick Actions & Stats */}
                    <div className="space-y-6">
                        <GlassCard className="p-6">
                            <h3 className="text-lg font-bold text-white mb-4">Ações Rápidas</h3>
                            <div className="space-y-3">
                                <QuickAction
                                    href="/admin/barbershops/new"
                                    icon={<Plus />}
                                    label="Nova Barbearia"
                                />
                                <QuickAction
                                    href="/admin/reports"
                                    icon={<TrendingUp />}
                                    label="Ver Relatórios"
                                />
                                <QuickAction
                                    href="/admin/settings"
                                    icon={<Settings />}
                                    label="Configurações"
                                />
                            </div>
                        </GlassCard>

                        <GlassCard className="p-6">
                            <h3 className="text-lg font-bold text-white mb-4">Resumo do Mês</h3>
                            <div className="space-y-4">
                                <div className="flex justify-between">
                                    <span className="text-gray-400">Total de Agendamentos</span>
                                    <span className="text-white font-bold">{stats.totalBookings}</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-gray-400">Assinaturas Ativas</span>
                                    <span className="text-green-400 font-bold">{stats.activePlans}</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-gray-400">Novos Clientes</span>
                                    <span className="text-blue-400 font-bold">-</span>
                                </div>
                            </div>
                        </GlassCard>
                    </div>
                </div>
            </main>
        </div>
    )
}

function StatCard({ icon, label, value, trend }: {
    icon: React.ReactNode
    label: string
    value: number
    trend?: string
}) {
    return (
        <GlassCard className="p-6">
            <div className="flex items-center gap-3 mb-3">
                {icon}
                <span className="text-gray-400 text-sm">{label}</span>
            </div>
            <div className="text-3xl font-bold text-white">{value}</div>
            {trend && <p className="text-xs text-green-400 mt-1">{trend}</p>}
        </GlassCard>
    )
}

function QuickAction({ href, icon, label }: { href: string; icon: React.ReactNode; label: string }) {
    return (
        <Link
            href={href}
            className="flex items-center gap-3 p-3 rounded-lg hover:bg-white/5 transition group"
        >
            <div className="text-gold">{icon}</div>
            <span className="text-gray-300 group-hover:text-white transition">{label}</span>
            <ChevronRight className="ml-auto text-gray-500 group-hover:text-gold transition" size={18} />
        </Link>
    )
}
