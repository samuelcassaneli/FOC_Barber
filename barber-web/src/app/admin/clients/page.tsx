'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { User, ArrowLeft, Calendar, Search, Mail } from 'lucide-react'
import Link from 'next/link'

interface Client {
    id: string
    full_name: string
    email: string
    avatar_url: string | null
    created_at: string
    bookings_count: number
}

export default function AdminClientsPage() {
    const router = useRouter()
    const [loading, setLoading] = useState(true)
    const [clients, setClients] = useState<Client[]>([])
    const [searchTerm, setSearchTerm] = useState('')

    useEffect(() => {
        const loadData = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (!user || user.email !== 'aiucmt.kiaaivmtq@gmail.com') {
                router.push('/dashboard')
                return
            }

            // Fetch all client profiles
            const { data: profiles } = await supabase
                .from('profiles')
                .select('id, full_name, email, avatar_url, created_at')
                .eq('role', 'client')
                .order('created_at', { ascending: false })

            // Get booking counts for each client
            const clientsWithCounts = await Promise.all(
                (profiles || []).map(async (profile) => {
                    const { count } = await supabase
                        .from('bookings')
                        .select('*', { count: 'exact' })
                        .eq('client_id', profile.id)

                    return {
                        ...profile,
                        bookings_count: count || 0
                    }
                })
            )

            setClients(clientsWithCounts)
            setLoading(false)
        }

        loadData()
    }, [router])

    const filteredClients = clients.filter(c =>
        c.full_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.email?.toLowerCase().includes(searchTerm.toLowerCase())
    )

    if (loading) {
        return <div className="min-h-screen bg-dark-bg flex items-center justify-center text-gold">Carregando...</div>
    }

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-6xl mx-auto">
                <header className="flex justify-between items-center mb-8">
                    <div className="flex items-center gap-4">
                        <Link href="/admin" className="p-2 rounded-lg hover:bg-white/10">
                            <ArrowLeft className="w-6 h-6 text-white" />
                        </Link>
                        <div>
                            <h1 className="text-3xl font-bold text-white">Gerenciar Clientes (LGPD)</h1>
                            <p className="text-gray-400">{clients.length} clientes cadastrados</p>
                        </div>
                    </div>
                </header>

                <GlassCard className="p-4 mb-6">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Buscar por nome ou email..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full pl-10 pr-4 py-3 rounded-lg bg-white/5 border border-white/10 text-white placeholder-gray-500"
                        />
                    </div>
                </GlassCard>

                <div className="grid gap-4">
                    {filteredClients.length === 0 ? (
                        <GlassCard className="p-8 text-center">
                            <User className="w-12 h-12 text-gray-500 mx-auto mb-4" />
                            <p className="text-gray-400">
                                {searchTerm ? 'Nenhum cliente encontrado.' : 'Nenhum cliente cadastrado.'}
                            </p>
                        </GlassCard>
                    ) : (
                        filteredClients.map((client) => (
                            <GlassCard key={client.id} className="p-4">
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-4">
                                        <div className="w-12 h-12 rounded-full bg-purple-500/20 flex items-center justify-center">
                                            {client.avatar_url ? (
                                                <img src={client.avatar_url} alt="" className="w-12 h-12 rounded-full object-cover" />
                                            ) : (
                                                <User className="w-6 h-6 text-purple-400" />
                                            )}
                                        </div>
                                        <div>
                                            <h3 className="text-lg font-semibold text-white">{client.full_name || 'Sem nome'}</h3>
                                            <p className="text-sm text-gray-400 flex items-center gap-1">
                                                <Mail className="w-3 h-3" /> {client.email}
                                            </p>
                                            <div className="flex gap-4 mt-1 text-sm">
                                                <span className="flex items-center gap-1 text-gray-400">
                                                    <Calendar className="w-3 h-3" /> {client.bookings_count} agendamentos
                                                </span>
                                                <span className="text-gray-500">
                                                    Desde {new Date(client.created_at).toLocaleDateString('pt-BR')}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </GlassCard>
                        ))
                    )}
                </div>

                <GlassCard className="p-4 mt-8 bg-blue-500/10 border-blue-500/20">
                    <p className="text-blue-300 text-sm">
                        <strong>Aviso LGPD:</strong> Os dados exibidos aqui são protegidos pela Lei Geral de Proteção de Dados.
                        Utilize apenas para fins de gestão do sistema.
                    </p>
                </GlassCard>
            </div>
        </div>
    )
}
