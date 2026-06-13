import {Routes, Route} from 'react-router-dom'
import Layout from './components/Layout'
import ProductList from './pages/ProductList'
import ProductDetail from './pages/ProductDetail'
import AddProduct from './pages/AddProduct'

export default function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<ProductList />} />
        <Route path="/product/:id" element={<ProductDetail />} />
        <Route path="/list-item" element={<AddProduct />} />
      </Routes>
    </Layout>
  )
}
