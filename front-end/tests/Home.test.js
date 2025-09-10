import { render, screen } from '@testing-library/react'
import Index from '../pages/index'

describe('Index Page', () => {
  it('renders the main heading', () => {
    render(<Index />)

    const headings = screen.getAllByText(
      /^Azubi Africa$/i
    )

    expect(headings[0]).toBeInTheDocument()
  })
})
