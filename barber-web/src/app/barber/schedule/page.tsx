'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Clock, Save } from 'lucide-react'

interface WorkingHours {
    id?: string
    day_of_week: number
    start_time: string
    end_time: string
    is_active: boolean
}

const DAYS = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado']

export default function BarberSchedulePage() {
    const router = useRouter()
    const [loading, setLoading] = useState(true)
    const [saving, setSaving] = useState(false)
    const [barberId, setBarberId] = useState<string | null>(null)
    const [schedule, setSchedule] = useState<WorkingHours[]>([])

    useEffect(() => {
        const loadData = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (!user) {
                router.push('/auth')
                return
            }

            // Get barber ID
            const { data: barber } = await supabase
                .from('barbers')
                .select('id')
                .eq('profile_id', user.id)
                .single()

            if (!barber) {
                router.push('/dashboard')
                return
            }

            setBarberId(barber.id)

            // Fetch working hours
            const { data: hoursData } = await supabase
                .from('working_hours')
                .select('*')
                .eq('barber_id', barber.id)
                .order('day_of_week')

            // Initialize all days with default values
            const initialSchedule: WorkingHours[] = Array.from({ length: 7 }, (_, i) => {
                const existing = hoursData?.find(h => h.day_of_week === i)
                return existing || {
                    day_of_week: i,
                    start_time: '09:00',
                    end_time: '18:00',
                    is_active: i !== 0 // Sunday inactive by default
                }
            })

            setSchedule(initialSchedule)
            setLoading(false)
        }

        loadData()
    }, [router])

    const updateDay = (dayIndex: number, field: keyof WorkingHours, value: string | boolean) => {
        setSchedule(prev => prev.map((day, i) =>
            i === dayIndex ? { ...day, [field]: value } : day
        ))
    }

    const handleSave = async () => {
        if (!barberId) return
        setSaving(true)

        try {
            // Delete existing and insert new
            await supabase
                .from('working_hours')
                .delete()
                .eq('barber_id', barberId)

            const activeHours = schedule.filter(s => s.is_active).map(s => ({
                barber_id: barberId,
                day_of_week: s.day_of_week,
                start_time: s.start_time,
                end_time: s.end_time
            }))

            if (activeHours.length > 0) {
                await supabase.from('working_hours').insert(activeHours)
            }

            alert('Horários salvos com sucesso!')
        } catch (error) {
            console.error('Error saving schedule:', error)
            alert('Erro ao salvar horários')
        } finally {
            setSaving(false)
        }
    }

    if (loading) {
        return <div className="min-h-screen bg-dark-bg flex items-center justify-center text-gold">Carregando...</div>
    }

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-2xl mx-auto">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <h1 className="text-3xl font-bold text-white">Horários de Trabalho</h1>
                        <p className="text-gray-400">Configure seus dias e horários de atendimento</p>
                    </div>
                    <GoldButton onClick={handleSave} disabled={saving}>
                        <Save className="w-4 h-4 mr-2" /> {saving ? 'Salvando...' : 'Salvar'}
                    </GoldButton>
                </header>

                <div className="space-y-4">
                    {schedule.map((day, index) => (
                        <GlassCard key={index} className={`p-4 ${!day.is_active ? 'opacity-50' : ''}`}>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-4">
                                    <label className="flex items-center gap-3 cursor-pointer">
                                        <input
                                            type="checkbox"
                                            checked={day.is_active}
                                            onChange={(e) => updateDay(index, 'is_active', e.target.checked)}
                                            className="w-5 h-5 rounded border-gray-600 bg-white/5 text-gold focus:ring-gold accent-gold"
                                        />
                                        <span className="text-white font-medium w-24">{DAYS[index]}</span>
                                    </label>
                                </div>

                                {day.is_active && (
                                    <div className="flex items-center gap-4">
                                        <div className="flex items-center gap-2">
                                            <Clock className="w-4 h-4 text-gray-400" />
                                            <input
                                                type="time"
                                                value={day.start_time}
                                                onChange={(e) => updateDay(index, 'start_time', e.target.value)}
                                                className="p-2 rounded-lg bg-white/5 border border-white/10 text-white text-sm"
                                            />
                                            <span className="text-gray-400">às</span>
                                            <input
                                                type="time"
                                                value={day.end_time}
                                                onChange={(e) => updateDay(index, 'end_time', e.target.value)}
                                                className="p-2 rounded-lg bg-white/5 border border-white/10 text-white text-sm"
                                            />
                                        </div>
                                    </div>
                                )}

                                {!day.is_active && (
                                    <span className="text-gray-500 text-sm">Fechado</span>
                                )}
                            </div>
                        </GlassCard>
                    ))}
                </div>

                <GlassCard className="p-4 mt-8 bg-blue-500/10 border-blue-500/20">
                    <div className="flex items-start gap-3">
                        <Clock className="w-5 h-5 text-blue-400 mt-0.5" />
                        <div>
                            <p className="text-blue-300 font-medium">Dica</p>
                            <p className="text-blue-200/70 text-sm">
                                Os horários definidos aqui serão usados para mostrar os slots disponíveis
                                para agendamento no app dos clientes.
                            </p>
                        </div>
                    </div>
                </GlassCard>
            </div>
        </div>
    )
}
