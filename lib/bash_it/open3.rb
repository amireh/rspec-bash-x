require 'open3'

module BashIt
  module Open3
    # an extended version of Open3.popen3 which exposes two pipes for internal
    # communication between the spawned process and ruby
    #
    # the descriptors are available as 62 (child read) and 63 (child write)
    def self.popen3X(*cmd, **opts, &block)
      in_r, in_w = IO.pipe
      out_r, out_w = IO.pipe
      err_r, err_w = IO.pipe
      b2r_r, b2r_w = IO.pipe
      r2b_r, r2b_w = IO.pipe

      opts[:in] = in_r
      opts[:out] = out_w
      opts[:err] = err_w
      opts[62] = r2b_r
      opts[63] = b2r_w

      env = {
        "BASHIT_R_FD" => "62",
        "BASHIT_W_FD" => "63"
      }

      ::Open3.send(:popen_run,
        [env] + cmd,
        opts,
        [in_r, out_w, err_w, r2b_r, b2r_w], # child_io
        [in_w, out_r, err_r, r2b_w, b2r_r], # parent_io
        &block
      )
    end
  end
end