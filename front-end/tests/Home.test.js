import { render, screen } from '@testing-library/react'
import Index from '../pages/index'

describe('Index Page', () => {
  it('renders the main heading', () => {
    render(<Index />)

    const heading = screen.getByText(
      /Albert/i
    )

    expect(heading).toBeInTheDocument()
  })
})
