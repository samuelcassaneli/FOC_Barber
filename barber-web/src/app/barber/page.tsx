'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Calendar, DollarSign, Clock, Scissors, Check, X } from 'lucide-react'
import Link from 'next/link'

interface BookingRaw {
  id: string
  start_time: string
  end_time: string
  status: string
  service: { name: string; price: number }[] | null
  client: { full_name: string }[] | null
}

interface Booking {
  id: string
  start_time: string
  end_time: string
  status: string
  service: { name: string; price: number } | null
  client: { full_name: string } | null
}

export default function BarberDashboard() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [barberName, setBarberName] = useState('')
  const [barberId, setBarberId] = useState<string | null>(null)
  const [bookings, setBookings] = useState<Booking[]>([])
  const [stats, setStats] = useState({
    todayBookings: 0,
    monthRevenue: 0,
    totalServices: 0
  })

  useEffect(() => {
    const checkBarber = async () => {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        router.push('/auth')
        return
      }

      // Check if user is a barber
      const { data: profile } = await supabase.from('profiles').select('role, full_name').eq('id', user.id).single()

      if (profile?.role !== 'barber' && profile?.role !== 'admin') {
        router.push('/dashboard') // Redirect clients
        return
      }

      setBarberName(profile.full_name)

      // Fetch Barber ID
      const { data: barber } = await supabase.from('barbers').select('id').eq('profile_id', user.id).single()

      if (barber) {
        setBarberId(barber.id)

        // Get today's bookings with service and client info
        const today = new Date()
        const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate()).toISOString()
        const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1).toISOString()

        const { data: todayBookingsRaw } = await supabase
          .from('bookings')
          .select(`
            id, start_time, end_time, status,
            service:services(name, price),
            client:profiles!bookings_client_id_fkey(full_name)
          `)
          .eq('barber_id', barber.id)
          .gte('start_time', startOfDay)
          .lt('start_time', endOfDay)
          .order('start_time')

        // Transform raw data to proper structure
        const todayBookings: Booking[] = (todayBookingsRaw as BookingRaw[] || []).map(b => ({
          ...b,
          service: Array.isArray(b.service) ? b.service[0] || null : b.service,
          client: Array.isArray(b.client) ? b.client[0] || null : b.client
        }))

        setBookings(todayBookings)

        // Get month revenue
        const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1).toISOString()
        const { data: monthBookingsRaw } = await supabase
          .from('bookings')
          .select('service:services(price)')
          .eq('barber_id', barber.id)
          .eq('status', 'completed')
          .gte('start_time', startOfMonth)

        const monthRevenue = (monthBookingsRaw || []).reduce((sum, b: { service: { price: number }[] | null }) => {
          const price = Array.isArray(b.service) ? b.service[0]?.price || 0 : 0
          return sum + price
        }, 0)

        // Get services count
        const { count: servicesCount } = await supabase
          .from('services')
          .select('*', { count: 'exact' })
          .eq('barber_id', barber.id)
          .eq('is_active', true)

        setStats({
          todayBookings: todayBookings?.length || 0,
          monthRevenue,
          totalServices: servicesCount || 0
        })
      }

      setLoading(false)
    }

    checkBarber()
  }, [router])

  const updateBookingStatus = async (bookingId: string, status: string) => {
    await supabase
      .from('bookings')
      .update({ status })
      .eq('id', bookingId)

    setBookings(bookings.map(b =>
      b.id === bookingId ? { ...b, status } : b
    ))
  }

  if (loading) return <div className="min-h-screen bg-dark-bg flex items-center justify-center text-gold">Carregando Painel do Barbeiro...</div>

  return (
    <div className="min-h-screen bg-dark-bg p-8">
      <div className="max-w-4xl mx-auto">
        <header className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-white">Olá, {barberName}</h1>
            <p className="text-gray-400">Gerencie sua agenda e serviços</p>
          </div>
          <div className="flex gap-4">
            <Link href="/barber/schedule">
              <GoldButton className="w-auto bg-white/10 border border-white/20 text-white hover:bg-white/20">Horários</GoldButton>
            </Link>
            <Link href="/barber/services">
              <GoldButton className="w-auto">Meus Serviços</GoldButton>
            </Link>
          </div>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <GlassCard className="p-6">
            <div className="flex items-center gap-4 mb-2">
              <div className="bg-blue-500/20 p-3 rounded-full text-blue-400">
                <Calendar className="w-6 h-6" />
              </div>
              <div>
                <p className="text-gray-400 text-sm">Agendamentos Hoje</p>
                <p className="text-2xl font-bold text-white">{stats.todayBookings}</p>
              </div>
            </div>
          </GlassCard>

          <GlassCard className="p-6">
            <div className="flex items-center gap-4 mb-2">
              <div className="bg-green-500/20 p-3 rounded-full text-green-400">
                <DollarSign className="w-6 h-6" />
              </div>
              <div>
                <p className="text-gray-400 text-sm">Faturamento Mês</p>
                <p className="text-2xl font-bold text-white">R$ {stats.monthRevenue.toFixed(0)}</p>
              </div>
            </div>
          </GlassCard>

          <GlassCard className="p-6">
            <div className="flex items-center gap-4 mb-2">
              <div className="bg-gold/20 p-3 rounded-full text-gold">
                <Scissors className="w-6 h-6" />
              </div>
              <div>
                <p className="text-gray-400 text-sm">Serviços Ativos</p>
                <p className="text-2xl font-bold text-white">{stats.totalServices}</p>
              </div>
            </div>
          </GlassCard>
        </div>

        <GlassCard className="p-6">
          <h2 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
            <Clock className="text-gold" /> Próximos Clientes
          </h2>
          <div className="space-y-4">
            {bookings.length === 0 ? (
              <p className="text-gray-400 text-center py-8">Nenhum agendamento para hoje</p>
            ) : (
              bookings.map((booking) => {
                const time = new Date(booking.start_time).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
                return (
                  <div key={booking.id} className="flex items-center justify-between p-4 bg-white/5 rounded-lg border border-white/5">
                    <div className="flex items-center gap-4">
                      <div className="text-center">
                        <p className="text-gold font-bold">{time}</p>
                        <p className="text-xs text-gray-500">Hoje</p>
                      </div>
                      <div>
                        <p className="text-white font-medium">{booking.client?.full_name || 'Cliente'}</p>
                        <p className="text-sm text-gray-400">{booking.service?.name || 'Serviço'}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      {booking.status === 'pending' ? (
                        <>
                          <button
                            onClick={() => updateBookingStatus(booking.id, 'confirmed')}
                            className="p-2 rounded-lg bg-green-500/20 text-green-400 hover:bg-green-500/30"
                          >
                            <Check className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => updateBookingStatus(booking.id, 'cancelled')}
                            className="p-2 rounded-lg bg-red-500/20 text-red-400 hover:bg-red-500/30"
                          >
                            <X className="w-4 h-4" />
                          </button>
                        </>
                      ) : (
                        <span className={`px-3 py-1 rounded-full text-xs ${booking.status === 'confirmed' ? 'bg-green-500/20 text-green-400' :
                          booking.status === 'cancelled' ? 'bg-red-500/20 text-red-400' :
                            'bg-yellow-500/20 text-yellow-400'
                          }`}>
                          {booking.status === 'confirmed' ? 'Confirmado' :
                            booking.status === 'cancelled' ? 'Cancelado' : booking.status}
                        </span>
                      )}
                    </div>
                  </div>
                )
              })
            )}
          </div>
        </GlassCard>
      </div>
    </div>
  )
}
