import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [users, setUsers] = useState([])
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [editingId, setEditingId] = useState(null)

  const fetchUsers = async () => {
    try {
      const res = await fetch('/api/users')
      const data = await res.json()
      setUsers(data)
    } catch (error) {
      console.error('Error fetching users:', error)
    }
  }

  useEffect(() => {
    fetchUsers()
  }, [])

  const handleSubmit = async (e) => {
    e.preventDefault()
    const url = editingId ? `/api/users/${editingId}` : '/api/users'
    const method = editingId ? 'PUT' : 'POST'

    try {
      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, email })
      })
      if (res.ok) {
        setName('')
        setEmail('')
        setEditingId(null)
        fetchUsers()
      } else {
        const err = await res.json()
        alert('Error: ' + err.detail)
      }
    } catch (error) {
      console.error('Error saving user:', error)
    }
  }

  const handleEdit = (user) => {
    setName(user.name)
    setEmail(user.email)
    setEditingId(user.id)
  }

  const handleDelete = async (id) => {
    if (!confirm('Are you sure?')) return
    try {
      const res = await fetch(`/api/users/${id}`, { method: 'DELETE' })
      if (res.ok) fetchUsers()
    } catch (error) {
      console.error('Error deleting user:', error)
    }
  }

  return (
    <div className="container">
      <h1>User Management System</h1>
      
      <div className="card">
        <h2>{editingId ? 'Edit User' : 'Add New User'}</h2>
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="Name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <button type="submit">{editingId ? 'Update' : 'Create'}</button>
          {editingId && (
            <button type="button" onClick={() => {
              setEditingId(null); setName(''); setEmail('');
            }}>Cancel</button>
          )}
        </form>
      </div>

      <div className="card">
        <h2>User List</h2>
        {users.length === 0 ? <p>No users found.</p> : (
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map(user => (
                <tr key={user.id}>
                  <td>{user.id}</td>
                  <td>{user.name}</td>
                  <td>{user.email}</td>
                  <td>
                    <button onClick={() => handleEdit(user)}>Edit</button>
                    <button onClick={() => handleDelete(user.id)} style={{backgroundColor: '#ff4444'}}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  )
}

export default App
