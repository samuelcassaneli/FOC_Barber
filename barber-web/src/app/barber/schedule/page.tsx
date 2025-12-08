'use client'

import { useState } from 'react'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import Link from 'next/link'

const DAYS = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo']

export default function ManageSchedulePage() {
    const [schedule, setSchedule] = useState(
        DAYS.map(day => ({ day, start: '09:00', end: '18:00', active: true }))
    )

    const toggleDay = (index: number) => {
        const newSchedule = [...schedule]
        newSchedule[index].active = !newSchedule[index].active
        setSchedule(newSchedule)
    }

    const updateTime = (index: number, field: 'start' | 'end', value: string) => {
        const newSchedule = [...schedule]
        newSchedule[index] = { ...newSchedule[index], [field]: value }
        setSchedule(newSchedule)
    }

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-2xl mx-auto">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <Link href="/barber" className="text-gray-400 hover:text-white text-sm mb-2 block">← Voltar ao Painel</Link>
                        <h1 className="text-3xl font-bold text-white">Configurar Horários</h1>
                    </div>
                    <GoldButton className="w-auto">Salvar Alterações</GoldButton>
                </header>

                <GlassCard className="p-6 space-y-4">
                    {schedule.map((slot, index) => (
                        <div key={slot.day} className={`flex items-center justify-between p-4 rounded-lg border transition-colors ${slot.active ? 'bg-white/5 border-white/10' : 'bg-transparent border-transparent opacity-50'}`}>
                            <div className="flex items-center gap-4">
                                <input
                                    type="checkbox"
                                    checked={slot.active}
                                    onChange={() => toggleDay(index)}
                                    className="w-5 h-5 rounded border-gray-600 text-gold focus:ring-gold bg-gray-700"
                                />
                                <span className="text-white font-medium w-24">{slot.day}</span>
                            </div>

                            <div className="flex items-center gap-4">
                                <input
                                    type="time"
                                    value={slot.start}
                                    disabled={!slot.active}
                                    onChange={(e) => updateTime(index, 'start', e.target.value)}
                                    className="bg-black/30 border border-white/10 rounded px-3 py-2 text-white disabled:opacity-50"
                                />
                                <span className="text-gray-500">até</span>
                                <input
                                    type="time"
                                    value={slot.end}
                                    disabled={!slot.active}
                                    onChange={(e) => updateTime(index, 'end', e.target.value)}
                                    className="bg-black/30 border border-white/10 rounded px-3 py-2 text-white disabled:opacity-50"
                                />
                            </div>
                        </div>
                    ))}
                </GlassCard>
            </div>
        </div>
    )
}
