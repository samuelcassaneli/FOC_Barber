'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Calendar, DollarSign, Clock, Scissors } from 'lucide-react'
import Link from 'next/link'

export default function BarberDashboard() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [barberName, setBarberName] = useState('')
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
        // Mock stats for now (real implementation would aggregate bookings)
        setStats({
          todayBookings: 5,
          monthRevenue: 3500,
          totalServices: 8
        })
      }

      setLoading(false)
    }

    checkBarber()
  }, [router])

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
                <p className="text-2xl font-bold text-white">R$ {stats.monthRevenue}</p>
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
            {/* Mock List */}
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex items-center justify-between p-4 bg-white/5 rounded-lg border border-white/5">
                <div className="flex items-center gap-4">
                  <div className="text-center">
                    <p className="text-gold font-bold">14:00</p>
                    <p className="text-xs text-gray-500">Hoje</p>
                  </div>
                  <div>
                    <p className="text-white font-medium">João Silva</p>
                    <p className="text-sm text-gray-400">Corte Degradê</p>
                  </div>
                </div>
                <span className="px-3 py-1 rounded-full text-xs bg-yellow-500/20 text-yellow-400">Confirmado</span>
              </div>
            ))}
          </div>
        </GlassCard>
      </div>
    </div>
  )
}
