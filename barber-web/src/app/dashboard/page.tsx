'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Booking } from '@/types'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Calendar, Clock, Scissors, ShieldCheck } from 'lucide-react'

export default function DashboardPage() {
    const router = useRouter()
    const [bookings, setBookings] = useState<Booking[]>([])
    const [loading, setLoading] = useState(true)
    const [userName, setUserName] = useState('')
    const [isAdmin, setIsAdmin] = useState(false)

    useEffect(() => {
        const fetchData = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (!user) {
                router.push('/auth')
                return
            }

            // Check if user is Super Admin
            if (user.email === 'aiucmt.kiaaivmtq@gmail.com') {
                setIsAdmin(true)
                setUserName('Super Admin')
                setLoading(false)
                return
            }

            // Fetch profile name
            const { data: profile } = await supabase
                .from('profiles')
                .select('full_name')
                .eq('id', user.id)
                .single()

            if (profile) setUserName(profile.full_name)

            // Fetch bookings
            const { data: bookingsData } = await supabase
                .from('bookings')
                .select(`
          *,
          barber:barbers(name),
          service:services(name, price, duration_minutes)
        `)
                .eq('client_id', user.id)
                .order('booking_date', { ascending: true })

            if (bookingsData) {
                setBookings(bookingsData as any)
            }
            setLoading(false)
        }

        fetchData()
    }, [router])

    const handleSignOut = async () => {
        await supabase.auth.signOut()
        router.push('/')
    }

    if (loading) {
        return <div className="min-h-screen bg-dark-bg flex items-center justify-center text-gold">Carregando...</div>
    }

    return (
        <div className="min-h-screen bg-dark-bg p-4 md:p-8">
            <div className="max-w-4xl mx-auto">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <h1 className="text-3xl font-bold text-white">Olá, <span className="text-gold">{userName}</span></h1>
                        <p className="text-gray-400">{isAdmin ? 'Bem-vindo ao Painel Master' : 'Gerencie seus agendamentos'}</p>
                    </div>
                    <button onClick={handleSignOut} className="text-sm text-red-400 hover:text-red-300">Sair</button>
                </header>

                {isAdmin ? (
                    <section className="flex flex-col gap-6">
                        <GlassCard className="p-8 text-center border-gold/30 bg-gold/5">
                            <ShieldCheck className="w-16 h-16 text-gold mx-auto mb-4" />
                            <h2 className="text-2xl font-bold text-white mb-2">Acesso Administrativo</h2>
                            <p className="text-gray-300 mb-6">Você tem acesso total ao sistema. Gerencie barbearias, clientes e visualize métricas.</p>
                            <Link href="/admin">
                                <GoldButton className="w-full md:w-auto px-8 py-3 text-lg">Acessar Painel Master</GoldButton>
                            </Link>
                        </GlassCard>
                    </section>
                ) : (
                    <section className="mb-8">
                        <div className="flex justify-between items-center mb-4">
                            <h2 className="text-xl font-semibold text-white">Próximos Agendamentos</h2>
                            <div className="flex gap-2">
                                <Link href="/search">
                                    <GoldButton className="w-auto py-2 px-4 text-sm bg-white/10 hover:bg-white/20 border-transparent">Encontrar Barbearia</GoldButton>
                                </Link>
                                <Link href="/book">
                                    <GoldButton className="w-auto py-2 px-4 text-sm">Novo Agendamento</GoldButton>
                                </Link>
                            </div>
                        </div>

                        {bookings.length === 0 ? (
                            <GlassCard className="p-8 text-center">
                                <p className="text-gray-400 mb-4">Você não tem agendamentos futuros.</p>
                                <Link href="/book">
                                    <GoldButton className="w-auto inline-block">Agendar Agora</GoldButton>
                                </Link>
                            </GlassCard>
                        ) : (
                            <div className="grid gap-4">
                                {bookings.map((booking) => (
                                    <GlassCard key={booking.id} className="p-4 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                                        <div className="flex items-start gap-4">
                                            <div className="bg-gold/10 p-3 rounded-lg">
                                                <Scissors className="text-gold w-6 h-6" />
                                            </div>
                                            <div>
                                                <h3 className="font-bold text-white text-lg">{booking.service?.name}</h3>
                                                <p className="text-gray-400 text-sm">com {booking.barber?.name}</p>
                                            </div>
                                        </div>

                                        <div className="flex flex-col md:items-end gap-1">
                                            <div className="flex items-center gap-2 text-gold">
                                                <Calendar className="w-4 h-4" />
                                                <span>{new Date(booking.booking_date).toLocaleDateString('pt-BR')}</span>
                                            </div>
                                            <div className="flex items-center gap-2 text-gray-300">
                                                <Clock className="w-4 h-4" />
                                                <span>{new Date(booking.booking_date).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}</span>
                                            </div>
                                        </div>

                                        <div className={`px-3 py-1 rounded-full text-xs font-bold uppercase
                     ${booking.status === 'confirmed' ? 'bg-green-500/20 text-green-400' :
                                                booking.status === 'pending' ? 'bg-yellow-500/20 text-yellow-400' : 'bg-red-500/20 text-red-400'}`}>
                                            {booking.status === 'confirmed' ? 'Confirmado' : booking.status === 'pending' ? 'Pendente' : booking.status}
                                        </div>
                                    </GlassCard>
                                ))}
                            </div>
                        )}
                    </section>
                )}
            </div>
        </div>
    )
}
