'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { Service, Barber } from '@/types'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { ChevronLeft, Check, Calendar as CalendarIcon, Clock } from 'lucide-react'

export default function BookingPage() {
    const router = useRouter()
    const [step, setStep] = useState(1)
    const [services, setServices] = useState<Service[]>([])
    const [barbers, setBarbers] = useState<Barber[]>([])

    const [selectedService, setSelectedService] = useState<Service | null>(null)
    const [selectedBarber, setSelectedBarber] = useState<Barber | null>(null)
    const [selectedDate, setSelectedDate] = useState('')
    const [selectedTime, setSelectedTime] = useState('')

    const [loading, setLoading] = useState(true)
    const [submitting, setSubmitting] = useState(false)

    // Fetch initial data
    useEffect(() => {
        const fetchData = async () => {
            const { data: servicesData } = await supabase.from('services').select('*')
            const { data: barbersData } = await supabase.from('barbers').select('*')

            if (servicesData) setServices(servicesData)
            if (barbersData) setBarbers(barbersData)
            setLoading(false)
        }
        fetchData()
    }, [])

    const handleNext = () => setStep(step + 1)
    const handleBack = () => setStep(step - 1)

    const handleSubmit = async () => {
        setSubmitting(true)
        try {
            const { data: { user } } = await supabase.auth.getUser()
            if (!user) throw new Error('User not authenticated')

            // Combine date and time
            const bookingDateTime = new Date(`${selectedDate}T${selectedTime}:00`).toISOString()

            const { error } = await supabase.from('bookings').insert({
                client_id: user.id,
                service_id: selectedService?.id,
                barber_id: selectedBarber?.id,
                booking_date: bookingDateTime,
                status: 'pending'
            })

            if (error) throw error

            router.push('/dashboard')
        } catch (error) {
            console.error('Error booking:', error)
            alert('Erro ao realizar agendamento. Tente novamente.')
        } finally {
            setSubmitting(false)
        }
    }

    if (loading) return <div className="min-h-screen bg-dark-bg flex items-center justify-center text-gold">Carregando...</div>

    return (
        <div className="min-h-screen bg-dark-bg p-4 md:p-8">
            <div className="max-w-2xl mx-auto">
                <header className="flex items-center mb-8">
                    <button onClick={() => step === 1 ? router.back() : handleBack()} className="text-white hover:text-gold mr-4">
                        <ChevronLeft />
                    </button>
                    <h1 className="text-2xl font-bold text-white">Novo Agendamento</h1>
                </header>

                {/* Progress Steps */}
                <div className="flex justify-between mb-8 relative">
                    <div className="absolute top-1/2 left-0 w-full h-0.5 bg-gray-800 -z-10" />
                    {[1, 2, 3, 4].map((s) => (
                        <div key={s} className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm transition-colors
              ${step >= s ? 'bg-gold text-black' : 'bg-gray-800 text-gray-400'}`}>
                            {s}
                        </div>
                    ))}
                </div>

                {/* Step 1: Service Selection */}
                {step === 1 && (
                    <div className="space-y-4">
                        <h2 className="text-xl text-white font-semibold mb-4">Escolha o Serviço</h2>
                        {services.map((service) => (
                            <GlassCard
                                key={service.id}
                                onClick={() => setSelectedService(service)}
                                className={`p-4 cursor-pointer transition-all hover:border-gold/50 flex justify-between items-center
                  ${selectedService?.id === service.id ? 'border-gold bg-gold/10' : ''}`}
                            >
                                <div>
                                    <h3 className="text-white font-bold">{service.name}</h3>
                                    <p className="text-gray-400 text-sm">{service.duration_minutes} min • R$ {service.price}</p>
                                </div>
                                {selectedService?.id === service.id && <Check className="text-gold" />}
                            </GlassCard>
                        ))}
                        <GoldButton disabled={!selectedService} onClick={handleNext} className="mt-8">Continuar</GoldButton>
                    </div>
                )}

                {/* Step 2: Barber Selection */}
                {step === 2 && (
                    <div className="space-y-4">
                        <h2 className="text-xl text-white font-semibold mb-4">Escolha o Barbeiro</h2>
                        {barbers.map((barber) => (
                            <GlassCard
                                key={barber.id}
                                onClick={() => setSelectedBarber(barber)}
                                className={`p-4 cursor-pointer transition-all hover:border-gold/50 flex items-center gap-4
                  ${selectedBarber?.id === barber.id ? 'border-gold bg-gold/10' : ''}`}
                            >
                                <div className="w-12 h-12 rounded-full bg-gray-700 overflow-hidden">
                                    {barber.photo_url ? (
                                        <img src={barber.photo_url} alt={barber.name} className="w-full h-full object-cover" />
                                    ) : (
                                        <div className="w-full h-full flex items-center justify-center text-gray-400">?</div>
                                    )}
                                </div>
                                <div className="flex-1">
                                    <h3 className="text-white font-bold">{barber.name}</h3>
                                    <p className="text-gray-400 text-sm">{barber.specialty}</p>
                                </div>
                                {selectedBarber?.id === barber.id && <Check className="text-gold" />}
                            </GlassCard>
                        ))}
                        <GoldButton disabled={!selectedBarber} onClick={handleNext} className="mt-8">Continuar</GoldButton>
                    </div>
                )}

                {/* Step 3: Date & Time */}
                {step === 3 && (
                    <div className="space-y-6">
                        <h2 className="text-xl text-white font-semibold mb-4">Data e Hora</h2>

                        <div>
                            <label className="block text-gray-400 mb-2">Data</label>
                            <input
                                type="date"
                                min={new Date().toISOString().split('T')[0]}
                                value={selectedDate}
                                onChange={(e) => setSelectedDate(e.target.value)}
                                className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-gold outline-none"
                            />
                        </div>

                        <div>
                            <label className="block text-gray-400 mb-2">Horário</label>
                            <div className="grid grid-cols-4 gap-2">
                                {['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'].map((time) => (
                                    <button
                                        key={time}
                                        onClick={() => setSelectedTime(time)}
                                        className={`p-2 rounded-lg text-sm font-medium transition-colors
                      ${selectedTime === time ? 'bg-gold text-black' : 'bg-white/5 text-white hover:bg-white/10'}`}
                                    >
                                        {time}
                                    </button>
                                ))}
                            </div>
                        </div>

                        <GoldButton disabled={!selectedDate || !selectedTime} onClick={handleNext} className="mt-8">Continuar</GoldButton>
                    </div>
                )}

                {/* Step 4: Confirmation */}
                {step === 4 && (
                    <div className="space-y-6">
                        <h2 className="text-xl text-white font-semibold mb-4">Confirmar Agendamento</h2>

                        <GlassCard className="p-6 space-y-4">
                            <div className="flex justify-between border-b border-white/10 pb-4">
                                <span className="text-gray-400">Serviço</span>
                                <span className="text-white font-medium">{selectedService?.name}</span>
                            </div>
                            <div className="flex justify-between border-b border-white/10 pb-4">
                                <span className="text-gray-400">Barbeiro</span>
                                <span className="text-white font-medium">{selectedBarber?.name}</span>
                            </div>
                            <div className="flex justify-between border-b border-white/10 pb-4">
                                <span className="text-gray-400">Data</span>
                                <span className="text-white font-medium">{new Date(selectedDate).toLocaleDateString('pt-BR')}</span>
                            </div>
                            <div className="flex justify-between border-b border-white/10 pb-4">
                                <span className="text-gray-400">Horário</span>
                                <span className="text-white font-medium">{selectedTime}</span>
                            </div>
                            <div className="flex justify-between pt-2">
                                <span className="text-gold font-bold text-lg">Total</span>
                                <span className="text-gold font-bold text-lg">R$ {selectedService?.price}</span>
                            </div>
                        </GlassCard>

                        <GoldButton onClick={handleSubmit} isLoading={submitting} className="mt-8">Confirmar Agendamento</GoldButton>
                    </div>
                )}
            </div>
        </div>
    )
}
