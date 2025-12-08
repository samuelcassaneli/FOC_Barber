'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Users, Calendar, DollarSign, TrendingUp, Activity, Store } from 'lucide-react'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

interface RevenueData {
    name: string
    value: number
}

export default function AdminDashboard() {
    const router = useRouter()
    const [loading, setLoading] = useState(true)
    const [revenueData, setRevenueData] = useState<RevenueData[]>([])
    const [stats, setStats] = useState({
        totalBookings: 0,
        totalRevenue: 0,
        activeBarbers: 0,
        activeClients: 0,
        todayBookings: 0
    })

    useEffect(() => {
        const checkAdmin = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (!user || user.email !== 'aiucmt.kiaaivmtq@gmail.com') {
                router.push('/dashboard')
                return
            }

            // Fetch Real Stats
            const { count: bookingsCount } = await supabase.from('bookings').select('*', { count: 'exact' })
            const { count: barbersCount } = await supabase.from('barbers').select('*', { count: 'exact' })
            const { count: clientsCount } = await supabase.from('profiles').select('*', { count: 'exact' }).eq('role', 'client')

            // Today's bookings
            const today = new Date()
            const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate()).toISOString()
            const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1).toISOString()
            const { count: todayCount } = await supabase
                .from('bookings')
                .select('*', { count: 'exact' })
                .gte('start_time', startOfDay)
                .lt('start_time', endOfDay)

            // Get revenue data for last 6 months
            const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']
            const revenueByMonth: RevenueData[] = []
            let totalRevenue = 0

            for (let i = 5; i >= 0; i--) {
                const date = new Date()
                date.setMonth(date.getMonth() - i)
                const startOfMonth = new Date(date.getFullYear(), date.getMonth(), 1).toISOString()
                const endOfMonth = new Date(date.getFullYear(), date.getMonth() + 1, 1).toISOString()

                const { data: monthBookings } = await supabase
                    .from('bookings')
                    .select('service:services(price)')
                    .eq('status', 'completed')
                    .gte('start_time', startOfMonth)
                    .lt('start_time', endOfMonth)

                const monthRevenue = (monthBookings || []).reduce((sum, b: any) => {
                    const price = Array.isArray(b.service) ? b.service[0]?.price || 0 : 0
                    return sum + price
                }, 0)

                revenueByMonth.push({
                    name: months[date.getMonth()],
                    value: monthRevenue
                })
                totalRevenue += monthRevenue
            }

            setRevenueData(revenueByMonth)
            setStats({
                totalBookings: bookingsCount || 0,
                totalRevenue,
                activeBarbers: barbersCount || 0,
                activeClients: clientsCount || 0,
                todayBookings: todayCount || 0
            })

            setLoading(false)
        }

        checkAdmin()
    }, [router])

    if (loading) return <div className="min-h-screen bg-dark-bg flex items-center justify-center text-gold">Carregando Painel SaaS...</div>

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-7xl mx-auto">
                <header className="flex justify-between items-center mb-10">
                    <div>
                        <h1 className="text-4xl font-bold text-white mb-2">Painel Master</h1>
                        <p className="text-gray-400">Visão geral do seu SaaS BarberPremium</p>
                    </div>
                    <div className="flex gap-4">
                        <GoldButton className="w-auto" onClick={() => router.push('/admin/clients')}>Gerenciar Clientes (LGPD)</GoldButton>
                        <GoldButton className="w-auto" onClick={() => router.push('/admin/barbers')}>Gerenciar Barbearias</GoldButton>
                    </div>
                </header>

                {/* Top Stats Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                    <GlassCard className="p-6 relative overflow-hidden group">
                        <div className="absolute right-0 top-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                            <DollarSign className="w-24 h-24 text-green-400" />
                        </div>
                        <div className="relative z-10">
                            <div className="flex items-center gap-3 mb-2">
                                <div className="bg-green-500/20 p-2 rounded-lg text-green-400">
                                    <DollarSign className="w-6 h-6" />
                                </div>
                                <span className="text-gray-400 text-sm font-medium">Receita Total</span>
                            </div>
                            <p className="text-3xl font-bold text-white">R$ {stats.totalRevenue.toLocaleString('pt-BR')}</p>
                            <p className="text-green-400 text-xs mt-2 flex items-center gap-1">
                                <TrendingUp className="w-3 h-3" /> +12.5% este mês
                            </p>
                        </div>
                    </GlassCard>

                    <GlassCard className="p-6 relative overflow-hidden group">
                        <div className="absolute right-0 top-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                            <Calendar className="w-24 h-24 text-blue-400" />
                        </div>
                        <div className="relative z-10">
                            <div className="flex items-center gap-3 mb-2">
                                <div className="bg-blue-500/20 p-2 rounded-lg text-blue-400">
                                    <Calendar className="w-6 h-6" />
                                </div>
                                <span className="text-gray-400 text-sm font-medium">Agendamentos</span>
                            </div>
                            <p className="text-3xl font-bold text-white">{stats.totalBookings}</p>
                            <p className="text-blue-400 text-xs mt-2 flex items-center gap-1">
                                <Activity className="w-3 h-3" /> {stats.todayBookings} hoje
                            </p>
                        </div>
                    </GlassCard>

                    <GlassCard className="p-6 relative overflow-hidden group">
                        <div className="absolute right-0 top-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                            <Store className="w-24 h-24 text-gold" />
                        </div>
                        <div className="relative z-10">
                            <div className="flex items-center gap-3 mb-2">
                                <div className="bg-gold/20 p-2 rounded-lg text-gold">
                                    <Store className="w-6 h-6" />
                                </div>
                                <span className="text-gray-400 text-sm font-medium">Barbearias Ativas</span>
                            </div>
                            <p className="text-3xl font-bold text-white">{stats.activeBarbers}</p>
                            <p className="text-gold text-xs mt-2">Parceiros Premium</p>
                        </div>
                    </GlassCard>

                    <GlassCard className="p-6 relative overflow-hidden group">
                        <div className="absolute right-0 top-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                            <Users className="w-24 h-24 text-purple-400" />
                        </div>
                        <div className="relative z-10">
                            <div className="flex items-center gap-3 mb-2">
                                <div className="bg-purple-500/20 p-2 rounded-lg text-purple-400">
                                    <Users className="w-6 h-6" />
                                </div>
                                <span className="text-gray-400 text-sm font-medium">Clientes Totais</span>
                            </div>
                            <p className="text-3xl font-bold text-white">{stats.activeClients}</p>
                            <p className="text-purple-400 text-xs mt-2">+5 novos hoje</p>
                        </div>
                    </GlassCard>
                </div>

                {/* Charts Section */}
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
                    <GlassCard className="p-6 lg:col-span-2">
                        <h2 className="text-xl font-bold text-white mb-6">Crescimento da Receita</h2>
                        <div className="h-[300px] w-full">
                            <ResponsiveContainer width="100%" height="100%">
                                <AreaChart data={revenueData}>
                                    <defs>
                                        <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%" stopColor="#D4AF37" stopOpacity={0.3} />
                                            <stop offset="95%" stopColor="#D4AF37" stopOpacity={0} />
                                        </linearGradient>
                                    </defs>
                                    <CartesianGrid strokeDasharray="3 3" stroke="#333" vertical={false} />
                                    <XAxis dataKey="name" stroke="#666" />
                                    <YAxis stroke="#666" />
                                    <Tooltip
                                        contentStyle={{ backgroundColor: '#1a1a1a', border: '1px solid #333', borderRadius: '8px' }}
                                        itemStyle={{ color: '#fff' }}
                                    />
                                    <Area type="monotone" dataKey="value" stroke="#D4AF37" fillOpacity={1} fill="url(#colorRevenue)" />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>
                    </GlassCard>

                    <GlassCard className="p-6">
                        <h2 className="text-xl font-bold text-white mb-6">Status da Plataforma</h2>
                        <div className="space-y-6">
                            <div>
                                <div className="flex justify-between text-sm mb-2">
                                    <span className="text-gray-400">Servidores (Vercel)</span>
                                    <span className="text-green-400">Operacional</span>
                                </div>
                                <div className="w-full bg-gray-800 rounded-full h-2">
                                    <div className="bg-green-500 h-2 rounded-full" style={{ width: '98%' }}></div>
                                </div>
                            </div>
                            <div>
                                <div className="flex justify-between text-sm mb-2">
                                    <span className="text-gray-400">Banco de Dados (Supabase)</span>
                                    <span className="text-green-400">Operacional</span>
                                </div>
                                <div className="w-full bg-gray-800 rounded-full h-2">
                                    <div className="bg-green-500 h-2 rounded-full" style={{ width: '100%' }}></div>
                                </div>
                            </div>
                            <div>
                                <div className="flex justify-between text-sm mb-2">
                                    <span className="text-gray-400">Armazenamento</span>
                                    <span className="text-yellow-400">65% Uso</span>
                                </div>
                                <div className="w-full bg-gray-800 rounded-full h-2">
                                    <div className="bg-yellow-500 h-2 rounded-full" style={{ width: '65%' }}></div>
                                </div>
                            </div>
                        </div>

                        <div className="mt-8 pt-6 border-t border-white/10">
                            <h3 className="text-white font-semibold mb-4">Ações Rápidas</h3>
                            <div className="space-y-3">
                                <button className="w-full text-left px-4 py-3 rounded-lg bg-white/5 hover:bg-white/10 text-gray-300 hover:text-white transition-colors text-sm flex items-center gap-2">
                                    <Users className="w-4 h-4" /> Aprovar Novos Barbeiros
                                </button>
                                <button className="w-full text-left px-4 py-3 rounded-lg bg-white/5 hover:bg-white/10 text-gray-300 hover:text-white transition-colors text-sm flex items-center gap-2">
                                    <DollarSign className="w-4 h-4" /> Configurar Taxas
                                </button>
                            </div>
                        </div>
                    </GlassCard>
                </div>
            </div>
        </div>
    )
}
