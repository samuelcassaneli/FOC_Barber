'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Plus, Edit, Trash2, Clock, DollarSign, Scissors } from 'lucide-react'

interface Service {
    id: string
    name: string
    description: string | null
    duration_min: number
    price: number
    is_active: boolean
}

export default function BarberServicesPage() {
    const router = useRouter()
    const [loading, setLoading] = useState(true)
    const [services, setServices] = useState<Service[]>([])
    const [barberId, setBarberId] = useState<string | null>(null)
    const [showForm, setShowForm] = useState(false)
    const [editingService, setEditingService] = useState<Service | null>(null)

    // Form state
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        duration_min: 30,
        price: 0
    })

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

            // Fetch services for this barber
            const { data: servicesData } = await supabase
                .from('services')
                .select('*')
                .eq('barber_id', barber.id)
                .order('name')

            setServices(servicesData || [])
            setLoading(false)
        }

        loadData()
    }, [router])

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()
        if (!barberId) return

        try {
            if (editingService) {
                await supabase
                    .from('services')
                    .update({
                        name: formData.name,
                        description: formData.description || null,
                        duration_min: formData.duration_min,
                        price: formData.price
                    })
                    .eq('id', editingService.id)
            } else {
                await supabase
                    .from('services')
                    .insert({
                        barber_id: barberId,
                        name: formData.name,
                        description: formData.description || null,
                        duration_min: formData.duration_min,
                        price: formData.price,
                        is_active: true
                    })
            }

            // Refresh services
            const { data: servicesData } = await supabase
                .from('services')
                .select('*')
                .eq('barber_id', barberId)
                .order('name')

            setServices(servicesData || [])
            setShowForm(false)
            setEditingService(null)
            setFormData({ name: '', description: '', duration_min: 30, price: 0 })
        } catch (error) {
            console.error('Error saving service:', error)
        }
    }

    const handleEdit = (service: Service) => {
        setEditingService(service)
        setFormData({
            name: service.name,
            description: service.description || '',
            duration_min: service.duration_min,
            price: service.price
        })
        setShowForm(true)
    }

    const handleDelete = async (serviceId: string) => {
        if (!confirm('Tem certeza que deseja excluir este serviço?')) return

        await supabase.from('services').delete().eq('id', serviceId)
        setServices(services.filter(s => s.id !== serviceId))
    }

    const toggleActive = async (service: Service) => {
        await supabase
            .from('services')
            .update({ is_active: !service.is_active })
            .eq('id', service.id)

        setServices(services.map(s =>
            s.id === service.id ? { ...s, is_active: !s.is_active } : s
        ))
    }

    if (loading) {
        return <div className="min-h-screen bg-dark-bg flex items-center justify-center text-gold">Carregando...</div>
    }

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-4xl mx-auto">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <h1 className="text-3xl font-bold text-white">Meus Serviços</h1>
                        <p className="text-gray-400">Gerencie os serviços que você oferece</p>
                    </div>
                    <GoldButton onClick={() => { setShowForm(true); setEditingService(null); setFormData({ name: '', description: '', duration_min: 30, price: 0 }); }}>
                        <Plus className="w-4 h-4 mr-2" /> Novo Serviço
                    </GoldButton>
                </header>

                {showForm && (
                    <GlassCard className="p-6 mb-8">
                        <h2 className="text-xl font-bold text-white mb-4">
                            {editingService ? 'Editar Serviço' : 'Novo Serviço'}
                        </h2>
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div>
                                <label className="block text-sm text-gray-400 mb-1">Nome do Serviço</label>
                                <input
                                    type="text"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    className="w-full p-3 rounded-lg bg-white/5 border border-white/10 text-white"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm text-gray-400 mb-1">Descrição (opcional)</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    className="w-full p-3 rounded-lg bg-white/5 border border-white/10 text-white"
                                    rows={2}
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm text-gray-400 mb-1">Duração (minutos)</label>
                                    <input
                                        type="number"
                                        value={formData.duration_min}
                                        onChange={(e) => setFormData({ ...formData, duration_min: parseInt(e.target.value) })}
                                        className="w-full p-3 rounded-lg bg-white/5 border border-white/10 text-white"
                                        min="5"
                                        step="5"
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm text-gray-400 mb-1">Preço (R$)</label>
                                    <input
                                        type="number"
                                        value={formData.price}
                                        onChange={(e) => setFormData({ ...formData, price: parseFloat(e.target.value) })}
                                        className="w-full p-3 rounded-lg bg-white/5 border border-white/10 text-white"
                                        min="0"
                                        step="0.01"
                                        required
                                    />
                                </div>
                            </div>
                            <div className="flex gap-4">
                                <GoldButton type="submit">
                                    {editingService ? 'Salvar' : 'Criar Serviço'}
                                </GoldButton>
                                <button
                                    type="button"
                                    onClick={() => { setShowForm(false); setEditingService(null); }}
                                    className="px-6 py-2 rounded-lg border border-white/20 text-white hover:bg-white/10"
                                >
                                    Cancelar
                                </button>
                            </div>
                        </form>
                    </GlassCard>
                )}

                <div className="grid gap-4">
                    {services.length === 0 ? (
                        <GlassCard className="p-8 text-center">
                            <Scissors className="w-12 h-12 text-gray-500 mx-auto mb-4" />
                            <p className="text-gray-400">Nenhum serviço cadastrado ainda.</p>
                            <p className="text-gray-500 text-sm">Clique em "Novo Serviço" para começar.</p>
                        </GlassCard>
                    ) : (
                        services.map((service) => (
                            <GlassCard key={service.id} className={`p-4 ${!service.is_active ? 'opacity-50' : ''}`}>
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-4">
                                        <div className="bg-gold/20 p-3 rounded-full">
                                            <Scissors className="w-5 h-5 text-gold" />
                                        </div>
                                        <div>
                                            <h3 className="text-lg font-semibold text-white">{service.name}</h3>
                                            {service.description && (
                                                <p className="text-sm text-gray-400">{service.description}</p>
                                            )}
                                            <div className="flex gap-4 mt-1 text-sm">
                                                <span className="flex items-center gap-1 text-gray-400">
                                                    <Clock className="w-3 h-3" /> {service.duration_min} min
                                                </span>
                                                <span className="flex items-center gap-1 text-green-400">
                                                    <DollarSign className="w-3 h-3" /> R$ {service.price.toFixed(2)}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <button
                                            onClick={() => toggleActive(service)}
                                            className={`px-3 py-1 rounded text-xs ${service.is_active
                                                    ? 'bg-green-500/20 text-green-400'
                                                    : 'bg-red-500/20 text-red-400'
                                                }`}
                                        >
                                            {service.is_active ? 'Ativo' : 'Inativo'}
                                        </button>
                                        <button
                                            onClick={() => handleEdit(service)}
                                            className="p-2 rounded-lg hover:bg-white/10 text-gray-400 hover:text-white"
                                        >
                                            <Edit className="w-4 h-4" />
                                        </button>
                                        <button
                                            onClick={() => handleDelete(service.id)}
                                            className="p-2 rounded-lg hover:bg-red-500/20 text-gray-400 hover:text-red-400"
                                        >
                                            <Trash2 className="w-4 h-4" />
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
