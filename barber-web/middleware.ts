import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
    let response = NextResponse.next({
        request: {
            headers: request.headers,
        },
    })

    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) {
                    return request.cookies.get(name)?.value
                },
                set(name: string, value: string, options: CookieOptions) {
                    request.cookies.set({
                        name,
                        value,
                        ...options,
                    })
                    response = NextResponse.next({
                        request: {
                            headers: request.headers,
                        },
                    })
                    response.cookies.set({
                        name,
                        value,
                        ...options,
                    })
                },
                remove(name: string, options: CookieOptions) {
                    request.cookies.set({
                        name,
                        value: '',
                        ...options,
                    })
                    response = NextResponse.next({
                        request: {
                            headers: request.headers,
                        },
                    })
                    response.cookies.set({
                        name,
                        value: '',
                        ...options,
                    })
                },
            },
        }
    )

    const { data: { session } } = await supabase.auth.getSession()

    // 1. Protect Admin Routes
    if (request.nextUrl.pathname.startsWith('/admin')) {
        if (!session) {
            return NextResponse.redirect(new URL('/auth', request.url))
        }
        if (session.user.email !== 'aiucmt.kiaaivmtq@gmail.com') {
            return NextResponse.redirect(new URL('/dashboard', request.url))
        }
    }

    // 2. Protect Barber Routes
    if (request.nextUrl.pathname.startsWith('/barber')) {
        if (!session) {
            return NextResponse.redirect(new URL('/auth', request.url))
        }
    }

    // 3. Redirect logged in users away from Auth
    if (request.nextUrl.pathname === '/auth') {
        if (session) {
            if (session.user.email === 'aiucmt.kiaaivmtq@gmail.com') {
                return NextResponse.redirect(new URL('/admin', request.url))
            }
            return NextResponse.redirect(new URL('/dashboard', request.url))
        }
    }

    return response
}

export const config = {
    matcher: ['/admin/:path*', '/barber/:path*', '/auth'],
}
