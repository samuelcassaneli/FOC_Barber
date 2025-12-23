'use client'

import { useState } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import {
    Store, ArrowLeft, Save, Shield,
    MapPin, Phone, Mail, Globe, Clock
} from 'lucide-react'

interface BarbershopForm {
    name: string
    slug: string
    description: string
    phone: string
    email: string
    website: string
    address: string
    city: string
    state: string
    zip_code: string
    is_active: boolean
}

const BRAZILIAN_STATES = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
]

export default function NewBarbershopPage() {
    const router = useRouter()
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)
    const [form, setForm] = useState<BarbershopForm>({
        name: '',
        slug: '',
        description: '',
        phone: '',
        email: '',
        website: '',
        address: '',
        city: '',
        state: '',
        zip_code: '',
        is_active: true
    })

    const generateSlug = (name: string) => {
        return name
            .toLowerCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/(^-|-$)/g, '')
    }

    const handleNameChange = (name: string) => {
        setForm(prev => ({
            ...prev,
            name,
            slug: generateSlug(name)
        }))
    }

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()
        setLoading(true)
        setError(null)

        try {
            // Validate required fields
            if (!form.name || !form.slug) {
                throw new Error('Nome e slug são obrigatórios')
            }

            // Check if slug is unique
            const { data: existing } = await supabase
                .from('barbershops')
                .select('id')
                .eq('slug', form.slug)
                .single()

            if (existing) {
                throw new Error('Este slug já está em uso. Escolha outro.')
            }

            // Get current user as owner
            const { data: { user } } = await supabase.auth.getUser()

            // Create barbershop
            const { data: barbershop, error: createError } = await supabase
                .from('barbershops')
                .insert({
                    name: form.name,
                    slug: form.slug,
                    description: form.description || null,
                    phone: form.phone || null,
                    email: form.email || null,
                    website: form.website || null,
                    address: form.address || null,
                    city: form.city || null,
                    state: form.state || null,
                    zip_code: form.zip_code || null,
                    is_active: form.is_active,
                    owner_id: user?.id || null,
                    settings: {
                        booking_advance_days: 30,
                        min_booking_notice_hours: 2,
                        cancellation_policy_hours: 24,
                        allow_client_cancellation: true,
                        require_payment_upfront: false
                    }
                })
                .select()
                .single()

            if (createError) throw createError

            // Redirect to barbershop detail page
            router.push(`/admin/barbershops/${barbershop.id}`)
        } catch (err: any) {
            setError(err.message || 'Erro ao criar barbearia')
        } finally {
            setLoading(false)
        }
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

            <main className="max-w-4xl mx-auto p-8">
                {/* Back Button */}
                <Link
                    href="/admin/barbershops"
                    className="inline-flex items-center gap-2 text-gray-400 hover:text-white transition mb-6"
                >
                    <ArrowLeft size={20} />
                    Voltar para Barbearias
                </Link>

                {/* Page Header */}
                <div className="flex items-center gap-4 mb-8">
                    <div className="w-16 h-16 bg-gold/20 rounded-xl flex items-center justify-center">
                        <Store className="text-gold" size={32} />
                    </div>
                    <div>
                        <h2 className="text-2xl font-bold text-white">Nova Barbearia</h2>
                        <p className="text-gray-400">Cadastre uma nova barbearia no sistema</p>
                    </div>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit}>
                    {error && (
                        <div className="bg-red-500/20 border border-red-500/50 text-red-400 px-4 py-3 rounded-lg mb-6">
                            {error}
                        </div>
                    )}

                    {/* Basic Info */}
                    <GlassCard className="p-6 mb-6">
                        <h3 className="text-lg font-bold text-white mb-4">Informações Básicas</h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="col-span-2">
                                <label className="block text-gray-400 text-sm mb-2">Nome da Barbearia *</label>
                                <input
                                    type="text"
                                    value={form.name}
                                    onChange={(e) => handleNameChange(e.target.value)}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="Ex: Barbearia Premium"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Slug (URL) *</label>
                                <div className="flex items-center">
                                    <span className="text-gray-500 mr-2">/</span>
                                    <input
                                        type="text"
                                        value={form.slug}
                                        onChange={(e) => setForm(prev => ({ ...prev, slug: e.target.value }))}
                                        className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                        placeholder="barbearia-premium"
                                        required
                                    />
                                </div>
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Status</label>
                                <select
                                    value={form.is_active ? 'active' : 'inactive'}
                                    onChange={(e) => setForm(prev => ({ ...prev, is_active: e.target.value === 'active' }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                >
                                    <option value="active">Ativo</option>
                                    <option value="inactive">Inativo</option>
                                </select>
                            </div>
                            <div className="col-span-2">
                                <label className="block text-gray-400 text-sm mb-2">Descrição</label>
                                <textarea
                                    value={form.description}
                                    onChange={(e) => setForm(prev => ({ ...prev, description: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50 h-24 resize-none"
                                    placeholder="Descrição da barbearia..."
                                />
                            </div>
                        </div>
                    </GlassCard>

                    {/* Contact Info */}
                    <GlassCard className="p-6 mb-6">
                        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
                            <Phone size={20} className="text-gold" />
                            Contato
                        </h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Telefone</label>
                                <input
                                    type="tel"
                                    value={form.phone}
                                    onChange={(e) => setForm(prev => ({ ...prev, phone: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="(11) 99999-9999"
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">E-mail</label>
                                <input
                                    type="email"
                                    value={form.email}
                                    onChange={(e) => setForm(prev => ({ ...prev, email: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="contato@barbearia.com"
                                />
                            </div>
                            <div className="col-span-2">
                                <label className="block text-gray-400 text-sm mb-2">Website</label>
                                <input
                                    type="url"
                                    value={form.website}
                                    onChange={(e) => setForm(prev => ({ ...prev, website: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="https://www.barbearia.com"
                                />
                            </div>
                        </div>
                    </GlassCard>

                    {/* Address */}
                    <GlassCard className="p-6 mb-6">
                        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
                            <MapPin size={20} className="text-gold" />
                            Endereço
                        </h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="col-span-2">
                                <label className="block text-gray-400 text-sm mb-2">Endereço</label>
                                <input
                                    type="text"
                                    value={form.address}
                                    onChange={(e) => setForm(prev => ({ ...prev, address: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="Rua, número, complemento"
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Cidade</label>
                                <input
                                    type="text"
                                    value={form.city}
                                    onChange={(e) => setForm(prev => ({ ...prev, city: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="São Paulo"
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Estado</label>
                                <select
                                    value={form.state}
                                    onChange={(e) => setForm(prev => ({ ...prev, state: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                >
                                    <option value="">Selecione...</option>
                                    {BRAZILIAN_STATES.map(state => (
                                        <option key={state} value={state}>{state}</option>
                                    ))}
                                </select>
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">CEP</label>
                                <input
                                    type="text"
                                    value={form.zip_code}
                                    onChange={(e) => setForm(prev => ({ ...prev, zip_code: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="00000-000"
                                />
                            </div>
                        </div>
                    </GlassCard>

                    {/* Actions */}
                    <div className="flex gap-4">
                        <Link
                            href="/admin/barbershops"
                            className="flex-1 text-center py-3 border border-white/20 text-gray-400 rounded-lg hover:bg-white/5 transition"
                        >
                            Cancelar
                        </Link>
                        <button
                            type="submit"
                            disabled={loading}
                            className="flex-1 flex items-center justify-center gap-2 bg-gold text-black py-3 rounded-lg font-medium hover:bg-gold/90 transition disabled:opacity-50"
                        >
                            {loading ? (
                                'Salvando...'
                            ) : (
                                <>
                                    <Save size={20} />
                                    Criar Barbearia
                                </>
                            )}
                        </button>
                    </div>
                </form>
            </main>
        </div>
    )
}
