// app/javascript/event_likes.js
// Handles asynchronous like/unlike actions on event show pages.

function setupEventLikeButtons() {
  document.querySelectorAll('.like-button').forEach(button => {
    // prevent double-binding
    if (button.dataset.bound === '1') return
    button.dataset.bound = '1'

    button.addEventListener('click', async (e) => {
      const btn = e.currentTarget
      const eventId = btn.dataset.eventId
      const liked = btn.dataset.liked === 'true' || btn.dataset.liked === '1'
      const likeId = btn.dataset.likeId

      try {
        if (!liked) {
          // create
          const res = await fetch(`/events/${eventId}/event_likes`, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content },
            credentials: 'same-origin'
          })
          if (!res.ok) throw res
          const json = await res.json()
          btn.dataset.liked = 'true'
          btn.dataset.likeId = json.like_id
          btn.querySelector('.count').textContent = json.likes_count
          btn.classList.add('liked')
        } else {
          // destroy
          if (!likeId) return
          const res = await fetch(`/events/${eventId}/event_likes/${likeId}`, {
            method: 'DELETE',
            headers: { 'Accept': 'application/json', 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content },
            credentials: 'same-origin'
          })
          if (!res.ok) throw res
          const json = await res.json()
          btn.dataset.liked = 'false'
          btn.dataset.likeId = ''
          btn.querySelector('.count').textContent = json.likes_count
          btn.classList.remove('liked')
        }
      } catch (err) {
        console.error('like action failed', err)
      }
    })
  })
}

document.addEventListener('turbo:load', () => {
  setupEventLikeButtons()
})

// in case of non-turbo navigation
document.addEventListener('DOMContentLoaded', () => {
  setupEventLikeButtons()
})

export { setupEventLikeButtons }
