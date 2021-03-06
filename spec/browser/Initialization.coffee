describe 'NoFlo UI initialization', ->
  win = null
  doc = null
  db = null
  before (done) ->
    @timeout 75000

    unless localStorage.getItem 'grid-token'
      # Fake login
      localStorage.setItem 'grid-token', '93c76ec0-d14b-11e3-9c1a-0800200c9a66'
      localStorage.setItem 'grid-user', JSON.stringify
        uuid: '11eecff0-d14c-11e3-9c1a-0800200c9a66'
        email: 'user@domain.com'
        name: 'Test User'
        avatar: 'https://secure.gravatar.com/avatar/995f27ce7205a79c55d4e44223cd6de0'

    iframe = document.getElementById 'app'
    iframe.src = '../../index.html'
    iframe.onload = ->
      win = iframe.contentWindow
      doc = iframe.contentDocument
      setTimeout ->
        done()
      , 5000
  after ->
    db.close()

  describe 'on startup', ->
    it 'should start the NoFlo process', (done) ->
      @timeout 75000
      checkNoFlo = ->
        chai.expect(win.nofloStarted).to.be.a 'boolean'
        if win.nofloDBReady
          chai.expect(win.nofloDBReady).to.be.a 'boolean'
          return done()
        setTimeout checkNoFlo, 1000
      setTimeout checkNoFlo, 1000

    it 'should start with the main screen', ->
      chai.expect(win.location.hash).to.equal ''

  describe 'NoFlo PrepareStorage', ->
    it 'should have created the IndexedDB database', (done) ->
      @timeout 4000
      indexedDB = win.overrideIndexedDB or win.indexedDB
      chai.expect(indexedDB).to.exist
      req = indexedDB.open 'noflo-ui', 4
      req.onerror = (err) ->
        done err
      req.onupgradeneeded = (e) ->
        e.target.transaction.abort()
        done new Error 'We didn\'t get a ready database'
      req.onsuccess = (event) ->
        db = event.target.result
        chai.expect(db.name).to.equal 'noflo-ui'
        chai.expect(db.version).to.equal 4
        done()
      return
    it 'should have created the project store', ->
      chai.expect(db.objectStoreNames.contains('projects')).to.equal true
    it 'should have created the graph store', ->
      chai.expect(db.objectStoreNames.contains('graphs')).to.equal true
    it 'should have created the component store', ->
      chai.expect(db.objectStoreNames.contains('components')).to.equal true
    it 'should have created the runtime store', ->
      chai.expect(db.objectStoreNames.contains('runtimes')).to.equal true
    it 'should have created the spec store', ->
      chai.expect(db.objectStoreNames.contains('specs')).to.equal true
