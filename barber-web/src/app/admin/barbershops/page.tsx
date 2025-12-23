'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import {
    Store, Search, Plus, ChevronRight,
    Filter, MoreVertical, Edit, Trash2,
    Users, Calendar, Shield
} from 'lucide-react'

interface Barbershop {
    id: string
    name: string
    slug: string
    city: string | null
    state: string | null
    phone: string | null
    email: string | null
    is_active: boolean
    created_at: string
    owner_id: string | null
    barber_count?: number
    booking_count?: number
}

export default function BarbershopsPage() {
    const router = useRouter()
    const [barbershops, setBarbershops] = useState<Barbershop[]>([])
    const [loading, setLoading] = useState(true)
    const [searchQuery, setSearchQuery] = useState('')
    const [filterActive, setFilterActive] = useState<'all' | 'active' | 'inactive'>('all')

    useEffect(() => {
        checkAdmin()
        fetchBarbershops()
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

    const fetchBarbershops = async () => {
        setLoading(true)

        const { data: shops, error } = await supabase
            .from('barbershops')
            .select('*')
            .order('created_at', { ascending: false })

        if (error) {
            console.error('Error fetching barbershops:', error)
            setLoading(false)
            return
        }

        // Fetch counts for each barbershop
        const shopsWithCounts = await Promise.all(
            (shops || []).map(async (shop) => {
                const [barberResult, bookingResult] = await Promise.all([
                    supabase
                        .from('barbers')
                        .select('*', { count: 'exact', head: true })
                        .eq('barbershop_id', shop.id),
                    supabase
                        .from('barbershop_bookings')
                        .select('*', { count: 'exact', head: true })
                        .eq('barbershop_id', shop.id)
                ])

                return {
                    ...shop,
                    barber_count: barberResult.count || 0,
                    booking_count: bookingResult.count || 0
                }
            })
        )

        setBarbershops(shopsWithCounts)
        setLoading(false)
    }

    const toggleActive = async (id: string, currentStatus: boolean) => {
        await supabase
            .from('barbershops')
            .update({ is_active: !currentStatus })
            .eq('id', id)

        setBarbershops(prev =>
            prev.map(shop =>
                shop.id === id ? { ...shop, is_active: !currentStatus } : shop
            )
        )
    }

    const deleteBarbershop = async (id: string) => {
        if (!confirm('Tem certeza que deseja excluir esta barbearia? Esta ação não pode ser desfeita.')) {
            return
        }

        await supabase
            .from('barbershops')
            .delete()
            .eq('id', id)

        setBarbershops(prev => prev.filter(shop => shop.id !== id))
    }

    const filteredBarbershops = barbershops.filter(shop => {
        const matchesSearch = shop.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            shop.slug.toLowerCase().includes(searchQuery.toLowerCase()) ||
            (shop.city?.toLowerCase().includes(searchQuery.toLowerCase()) ?? false)

        const matchesFilter = filterActive === 'all' ||
            (filterActive === 'active' && shop.is_active) ||
            (filterActive === 'inactive' && !shop.is_active)

        return matchesSearch && matchesFilter
    })

    if (loading) {
        return (
            <div className="min-h-screen bg-dark-bg flex items-center justify-center">
                <div className="text-gold text-xl">Carregando barbearias...</div>
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
                        <Link href="/admin" className="text-gray-400 hover:text-white transition">Dashboard</Link>
                        <Link href="/admin/barbershops" className="text-gold font-medium">Barbearias</Link>
                        <Link href="/admin/users" className="text-gray-400 hover:text-white transition">Usuários</Link>
                        <Link href="/admin/financial" className="text-gray-400 hover:text-white transition">Financeiro</Link>
                    </nav>
                </div>
            </header>

            <main className="max-w-7xl mx-auto p-8">
                {/* Page Header */}
                <div className="flex justify-between items-center mb-8">
                    <div>
                        <h2 className="text-2xl font-bold text-white">Barbearias</h2>
                        <p className="text-gray-400 mt-1">Gerencie todas as barbearias do sistema</p>
                    </div>
                    <Link
                        href="/admin/barbershops/new"
                        className="flex items-center gap-2 bg-gold text-black px-6 py-3 rounded-lg font-medium hover:bg-gold/90 transition"
                    >
                        <Plus size={20} />
                        Nova Barbearia
                    </Link>
                </div>

                {/* Filters */}
                <div className="flex gap-4 mb-6">
                    <div className="flex-1 relative">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500" size={20} />
                        <input
                            type="text"
                            placeholder="Buscar por nome, slug ou cidade..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="w-full bg-dark-card border border-white/10 rounded-lg pl-12 pr-4 py-3 text-white placeholder-gray-500 focus:outline-none focus:border-gold/50"
                        />
                    </div>
                    <div className="flex gap-2">
                        <button
                            onClick={() => setFilterActive('all')}
                            className={`px-4 py-2 rounded-lg transition ${
                                filterActive === 'all'
                                    ? 'bg-gold text-black'
                                    : 'bg-dark-card text-gray-400 hover:text-white'
                            }`}
                        >
                            Todas
                        </button>
                        <button
                            onClick={() => setFilterActive('active')}
                            className={`px-4 py-2 rounded-lg transition ${
                                filterActive === 'active'
                                    ? 'bg-green-500 text-white'
                                    : 'bg-dark-card text-gray-400 hover:text-white'
                            }`}
                        >
                            Ativas
                        </button>
                        <button
                            onClick={() => setFilterActive('inactive')}
                            className={`px-4 py-2 rounded-lg transition ${
                                filterActive === 'inactive'
                                    ? 'bg-red-500 text-white'
                                    : 'bg-dark-card text-gray-400 hover:text-white'
                            }`}
                        >
                            Inativas
                        </button>
                    </div>
                </div>

                {/* Stats Summary */}
                <div className="grid grid-cols-3 gap-4 mb-8">
                    <GlassCard className="p-4">
                        <div className="text-gray-400 text-sm">Total</div>
                        <div className="text-2xl font-bold text-white">{barbershops.length}</div>
                    </GlassCard>
                    <GlassCard className="p-4">
                        <div className="text-gray-400 text-sm">Ativas</div>
                        <div className="text-2xl font-bold text-green-400">
                            {barbershops.filter(s => s.is_active).length}
                        </div>
                    </GlassCard>
                    <GlassCard className="p-4">
                        <div className="text-gray-400 text-sm">Inativas</div>
                        <div className="text-2xl font-bold text-red-400">
                            {barbershops.filter(s => !s.is_active).length}
                        </div>
                    </GlassCard>
                </div>

                {/* Barbershops List */}
                <div className="space-y-4">
                    {filteredBarbershops.length === 0 ? (
                        <GlassCard className="p-12 text-center">
                            <Store className="mx-auto text-gray-500 mb-4" size={64} />
                            <h3 className="text-xl font-bold text-white mb-2">Nenhuma barbearia encontrada</h3>
                            <p className="text-gray-400 mb-6">
                                {searchQuery
                                    ? 'Tente ajustar sua busca'
                                    : 'Comece cadastrando a primeira barbearia'}
                            </p>
                            {!searchQuery && (
                                <Link
                                    href="/admin/barbershops/new"
                                    className="inline-flex items-center gap-2 bg-gold text-black px-6 py-3 rounded-lg font-medium hover:bg-gold/90 transition"
                                >
                                    <Plus size={20} />
                                    Cadastrar Barbearia
                                </Link>
                            )}
                        </GlassCard>
                    ) : (
                        filteredBarbershops.map(shop => (
                            <GlassCard key={shop.id} className="p-6">
                                <div className="flex justify-between items-start">
                                    <div className="flex items-start gap-4">
                                        <div className="w-16 h-16 bg-gold/20 rounded-xl flex items-center justify-center">
                                            <Store className="text-gold" size={32} />
                                        </div>
                                        <div>
                                            <div className="flex items-center gap-3">
                                                <h3 className="text-xl font-bold text-white">{shop.name}</h3>
                                                <span className={`px-3 py-1 rounded-full text-xs ${
                                                    shop.is_active
                                                        ? 'bg-green-500/20 text-green-400'
                                                        : 'bg-red-500/20 text-red-400'
                                                }`}>
                                                    {shop.is_active ? 'Ativo' : 'Inativo'}
                                                </span>
                                            </div>
                                            <p className="text-gray-400 text-sm mt-1">
                                                /{shop.slug} • {shop.city || 'Sem cidade'}, {shop.state || 'N/A'}
                                            </p>
                                            <div className="flex gap-6 mt-3 text-sm">
                                                <div className="flex items-center gap-2 text-gray-400">
                                                    <Users size={16} />
                                                    <span>{shop.barber_count} barbeiros</span>
                                                </div>
                                                <div className="flex items-center gap-2 text-gray-400">
                                                    <Calendar size={16} />
                                                    <span>{shop.booking_count} agendamentos</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div className="flex items-center gap-2">
                                        <Link
                                            href={`/admin/barbershops/${shop.id}`}
                                            className="p-2 rounded-lg bg-white/5 hover:bg-white/10 transition text-gray-400 hover:text-white"
                                        >
                                            <Edit size={18} />
                                        </Link>
                                        <button
                                            onClick={() => toggleActive(shop.id, shop.is_active)}
                                            className={`px-3 py-2 rounded-lg text-sm transition ${
                                                shop.is_active
                                                    ? 'bg-red-500/20 text-red-400 hover:bg-red-500/30'
                                                    : 'bg-green-500/20 text-green-400 hover:bg-green-500/30'
                                            }`}
                                        >
                                            {shop.is_active ? 'Desativar' : 'Ativar'}
                                        </button>
                                        <button
                                            onClick={() => deleteBarbershop(shop.id)}
                                            className="p-2 rounded-lg bg-red-500/10 hover:bg-red-500/20 transition text-red-400"
                                        >
                                            <Trash2 size={18} />
                                        </button>
                                    </div>
                                </div>
                            </GlassCard>
                        ))
                    )}
                </div>
            </main>
        </div>
    )
}
