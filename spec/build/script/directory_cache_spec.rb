require 'spec_helper'

describe Travis::Build::Script::DirectoryCache do
  let(:options) { { fetch_timeout: 20, push_timeout: 30, type: 's3', s3: { bucket: 's3_bucket', secret_access_key: 's3_secret_access_key', access_key_id: 's3_access_key_id' } } }
  let(:data)    { payload_for(:push, :erlang, config: { cache: config }, cache_options: options) }
  let(:sh)      { Travis::Shell::Builder.new }
  let(:script)  { Struct.new(:sh, :data, :cache_slug) { include(Travis::Build::Script::DirectoryCache) }.new(sh, Travis::Build::Data.new(data)) }
  let(:cache)   { script.directory_cache }

  it_behaves_like 'compiled script' do
    let(:config) { { directories: ['foo'] } }
    let(:cmds)   { ['cache.1', 'cache.2', 'casher fetch', 'casher add', 'casher push'] }
  end

  describe 'with no caching enabled' do
    let(:config) { {} }
    it { expect(script).not_to be_use_directory_cache }
    it { expect(cache).to be_a(Travis::Build::Script::DirectoryCache::Noop) }
  end

  describe 'uses S3 with caching enabled' do
    let(:config) { { directories: ['foo'] } }
    it { expect(script).to be_use_directory_cache }
    it { expect(cache).to be_a(Travis::Build::Script::DirectoryCache::S3) }
  end
end
