'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Users, Star, Calendar, ArrowLeft, Ban, CheckCircle } from 'lucide-react'
import Link from 'next/link'

interface Barber {
    id: string
    is_available: boolean
    rating: number | null
    profile: {
        full_name: string
        email: string
        avatar_url: string | null
    }
    bookings_count: number
}

export default function AdminBarbersPage() {
    const router = useRouter()
    const [loading, setLoading] = useState(true)
    const [barbers, setBarbers] = useState<Barber[]>([])

    useEffect(() => {
        const loadData = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (!user || user.email !== 'aiucmt.kiaaivmtq@gmail.com') {
                router.push('/dashboard')
                return
            }

            // Fetch all barbers with their profiles
            const { data: barbersData } = await supabase
                .from('barbers')
                .select(`
          id, is_available, rating,
          profile:profiles!barbers_profile_id_fkey(full_name, email, avatar_url)
        `)

            // Get booking counts for each barber
            const barbersWithCounts = await Promise.all(
                (barbersData || []).map(async (barber: any) => {
                    const { count } = await supabase
                        .from('bookings')
                        .select('*', { count: 'exact' })
                        .eq('barber_id', barber.id)

                    return {
                        ...barber,
                        profile: Array.isArray(barber.profile) ? barber.profile[0] : barber.profile,
                        bookings_count: count || 0
                    }
                })
            )

            setBarbers(barbersWithCounts)
            setLoading(false)
        }

        loadData()
    }, [router])

    const toggleAvailability = async (barberId: string, currentStatus: boolean) => {
        await supabase
            .from('barbers')
            .update({ is_available: !currentStatus })
            .eq('id', barberId)

        setBarbers(barbers.map(b =>
            b.id === barberId ? { ...b, is_available: !currentStatus } : b
        ))
    }

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
                            <h1 className="text-3xl font-bold text-white">Gerenciar Barbearias</h1>
                            <p className="text-gray-400">{barbers.length} barbeiros cadastrados</p>
                        </div>
                    </div>
                </header>

                <div className="grid gap-4">
                    {barbers.length === 0 ? (
                        <GlassCard className="p-8 text-center">
                            <Users className="w-12 h-12 text-gray-500 mx-auto mb-4" />
                            <p className="text-gray-400">Nenhum barbeiro cadastrado.</p>
                        </GlassCard>
                    ) : (
                        barbers.map((barber) => (
                            <GlassCard key={barber.id} className={`p-4 ${!barber.is_available ? 'opacity-60' : ''}`}>
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-4">
                                        <div className="w-12 h-12 rounded-full bg-gold/20 flex items-center justify-center">
                                            {barber.profile?.avatar_url ? (
                                                <img src={barber.profile.avatar_url} alt="" className="w-12 h-12 rounded-full object-cover" />
                                            ) : (
                                                <Users className="w-6 h-6 text-gold" />
                                            )}
                                        </div>
                                        <div>
                                            <h3 className="text-lg font-semibold text-white">{barber.profile?.full_name || 'Sem nome'}</h3>
                                            <p className="text-sm text-gray-400">{barber.profile?.email}</p>
                                            <div className="flex gap-4 mt-1 text-sm">
                                                <span className="flex items-center gap-1 text-gray-400">
                                                    <Calendar className="w-3 h-3" /> {barber.bookings_count} agendamentos
                                                </span>
                                                <span className="flex items-center gap-1 text-yellow-400">
                                                    <Star className="w-3 h-3" /> {barber.rating?.toFixed(1) || 'N/A'}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <button
                                            onClick={() => toggleAvailability(barber.id, barber.is_available)}
                                            className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm ${barber.is_available
                                                    ? 'bg-green-500/20 text-green-400 hover:bg-green-500/30'
                                                    : 'bg-red-500/20 text-red-400 hover:bg-red-500/30'
                                                }`}
                                        >
                                            {barber.is_available ? (
                                                <>
                                                    <CheckCircle className="w-4 h-4" /> Ativo
                                                </>
                                            ) : (
                                                <>
                                                    <Ban className="w-4 h-4" /> Inativo
                                                </>
                                            )}
                                        </button>
                                    </div>
                                </div>
                            </GlassCard>
                        ))
                    )}
                </div>
            </div>
        </div>
    )
}
