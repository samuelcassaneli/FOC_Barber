'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Service } from '@/types'
import { Trash2, Edit2, Plus } from 'lucide-react'
import Link from 'next/link'

export default function ManageServicesPage() {
    const [services, setServices] = useState<Service[]>([])
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        fetchServices()
    }, [])

    const fetchServices = async () => {
        const { data } = await supabase.from('services').select('*')
        if (data) setServices(data)
        setLoading(false)
    }

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-4xl mx-auto">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <Link href="/barber" className="text-gray-400 hover:text-white text-sm mb-2 block">← Voltar ao Painel</Link>
                        <h1 className="text-3xl font-bold text-white">Meus Serviços</h1>
                    </div>
                    <GoldButton className="w-auto flex items-center gap-2">
                        <Plus className="w-4 h-4" /> Novo Serviço
                    </GoldButton>
                </header>

                <div className="grid gap-4">
                    {services.map((service) => (
                        <GlassCard key={service.id} className="p-4 flex justify-between items-center">
                            <div>
                                <h3 className="text-white font-bold text-lg">{service.name}</h3>
                                <p className="text-gray-400">{service.description}</p>
                                <div className="flex gap-4 mt-2 text-sm">
                                    <span className="text-gold">R$ {service.price}</span>
                                    <span className="text-gray-500">•</span>
                                    <span className="text-gray-300">{service.duration_minutes} min</span>
                                </div>
                            </div>
                            <div className="flex gap-2">
                                <button className="p-2 hover:bg-white/10 rounded-lg text-gray-400 hover:text-white">
                                    <Edit2 className="w-4 h-4" />
                                </button>
                                <button className="p-2 hover:bg-red-500/20 rounded-lg text-gray-400 hover:text-red-400">
                                    <Trash2 className="w-4 h-4" />
                                </button>
                            </div>
                        </GlassCard>
                    ))}
                </div>
            </div>
        </div>
    )
}
